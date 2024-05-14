# typed: strong
# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "message_helper"

describe CapnProto::StreamMessage, nil do
  describe ".from_buffer" do
    it "creates a new message from a buffer" do
      expect(MessageHelper.single_segment).must_be_instance_of(CapnProto::StreamMessage)
    end

    it "extracts the number of segments from the message" do
      expect(MessageHelper.single_segment.segments.length).must_equal(1)
      expect(MessageHelper.four_segment.segments.length).must_equal(4)
    end

    it "creates segments with the correct sizes" do
      expect(MessageHelper.single_segment.segments.fetch(0).size).must_equal(8)

      four_segments = MessageHelper.four_segment.segments
      expect(four_segments.fetch(0).size).must_equal(56)
      expect(four_segments.fetch(1).size).must_equal(16)
      expect(four_segments.fetch(2).size).must_equal(56)
      expect(four_segments.fetch(3).size).must_equal(40)
    end

    it "raises an error if the number of sizes does not match the number of segments" do
      data = T.let([
        3, # Number of segments (minus one)
        1, # Size of segment 0 (in words)
        2  # Size of segment 1
        # MISSING
      ].pack("L<*"), String)
      expect { CapnProto::StreamMessage.new(CapnProto::IOBuffer.new(IO::Buffer.for(data))) }
        .must_raise("Not enough segment sizes provided")
    end

    it "raises an error if the buffer is too small for given segment sizes" do
      data = T.let([
        0,    # Number of segments (minus one)
        9999, # Size of segment 0 (in words)
        1234, # Segment 0
        5678
      ].pack("L<*"), String)
      expect { CapnProto::StreamMessage.new(CapnProto::IOBuffer.new(IO::Buffer.for(data))) }
        .must_raise("Buffer smaller than provided segment sizes")
    end
  end

  describe "#root" do
    it "returns a reference to the first pointer in the first segment" do
      # Get the root pointer
      root = MessageHelper.four_segment.root

      # Verify the root pointer
      expect(root.position).must_equal(0)
    end
  end

  describe "#dereference_pointer" do
    context "not a far pointer" do
      it "returns the original pointer" do
        # MessageSpecHelpers.single_segment contains a struct pointer
        pointer = MessageHelper.single_segment.root
        expect(MessageHelper.single_segment.dereference_pointer(pointer)).must_equal([pointer, nil])
      end
    end

    context "single far pointer" do
      it "dereferences a far pointer to a higher segment" do
        # 0+00: Single far pointer -> 1+00: STRUCT_POINTER_D
        pointer = MessageHelper.four_segment.segments.fetch(0).to_reference
        ref, content = MessageHelper.four_segment.dereference_pointer(pointer)
        expect(ref.read_integer(0, false, 64)).must_equal(MessageHelper::STRUCT_POINTER_D)
        expect(content).must_be_nil
      end

      it "dereferences a far pointer to a lower segment" do
        # 1+08: Single far pointer -> 0+08: STRUCT_POINTER_A
        pointer = MessageHelper.four_segment.segments.fetch(1).to_reference.offset_position(8)
        ref, content = MessageHelper.four_segment.dereference_pointer(pointer)
        expect(ref.read_integer(0, false, 64)).must_equal(MessageHelper::STRUCT_POINTER_A)
        expect(content).must_be_nil
      end

      it "raises an error if the segment ID is unknown" do
        # 0+16: Single far pointer -> 9+00: Invalid segment
        pointer = MessageHelper.four_segment.segments.fetch(0).to_reference.offset_position(16)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "Unknown segment ID 9 in far pointer")
      end

      it "raises an error if the offset is outside the targeted segment" do
        # 0+32: Single far pointer -> 1+32: Invalid offset
        pointer = MessageHelper.four_segment.segments.fetch(0).to_reference.offset_position(32)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "Invalid offset 32 for segment 1 in far pointer")
      end
    end

    context "double far pointer" do
      it "dereferences a far pointer to a higher segment" do
        # 2+00: Double far pointer -> 0+00: Single far pointer     -> 1+00: STRUCT_POINTER_D
        #                             0+08: Tag (STRUCT_POINTER_A)
        pointer = MessageHelper.four_segment.segments.fetch(2).to_reference
        ref, content = MessageHelper.four_segment.dereference_pointer(pointer)
        expect(ref.read_integer(0, false, 64)).must_equal(MessageHelper::STRUCT_POINTER_A)
        expect(content&.read_integer(0, false, 64)).must_equal(MessageHelper::STRUCT_POINTER_D)
      end

      it "raises an error if the segment ID is unknown" do
        # 2+08: Double far pointer -> 8+16: Invalid segment
        pointer = MessageHelper.four_segment.segments.fetch(2).to_reference.offset_position(8)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "Unknown segment ID 8 in far pointer")
      end

      it "raises an error if the offset is outside the targeted segment" do
        # 2+16: Double far pointer -> 1+64: Invalid offset
        pointer = MessageHelper.four_segment.segments.fetch(2).to_reference.offset_position(16)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "Invalid offset 64 for segment 1 in far pointer")
      end

      it "raises an error if the nested far pointer is a double pointer" do
        # 0+48: Double far pointer -> 2+00: Double far pointer -> Error
        pointer = MessageHelper.four_segment.segments.fetch(0).to_reference.offset_position(48)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "Double far pointer pointing to another double far pointer")
      end

      it "raises an error if the first word is not a nested far pointer" do
        # 2+24: Double far pointer -> 1+00: STRUCT_POINTER_D
        pointer = MessageHelper.four_segment.segments.fetch(2).to_reference.offset_position(24)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "First word of double far pointer is not a far pointer")
      end

      it "raises an error if the second word is outside the segment" do
        # 2+32: Double far pointer -> 1+08: Single far pointer
        #                             1+16: Invalid offset
        pointer = MessageHelper.four_segment.segments.fetch(2).to_reference.offset_position(32)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "Invalid offset 8 for segment 1 in far pointer")
      end

      it "raises an error if the nested far pointer refers to an unknown segment" do
        # 2+40: Double far pointer -> 0+16: Single far pointer -> 9+00: Invalid segment
        #                             0+24: STRUCT_POINTER_B
        pointer = MessageHelper.four_segment.segments.fetch(2).to_reference.offset_position(40)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "Unknown segment ID 9 in far pointer")
      end

      it "raises an error if the nested far pointer refers to an offset outside the segment" do
        # 2+48: Double far pointer -> 0+32: Single far pointer -> 1+32: Invalid offset
        #                             0+40: STRUCT_POINTER_C
        pointer = MessageHelper.four_segment.segments.fetch(2).to_reference.offset_position(48)
        expect { MessageHelper.four_segment.dereference_pointer(pointer) }
          .must_raise(CapnProto::Error, "Invalid offset 32 for segment 1 in far pointer")
      end
    end
  end
end
