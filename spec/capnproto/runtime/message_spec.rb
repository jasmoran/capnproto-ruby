# typed: false
# frozen_string_literal: true

def build_far_pointer(single, segment_id, offset)
  type = single ? 2 : 6
  type | (offset / 8) << 3 | segment_id << 32
end

STRUCT_POINTER_A = 0xA1A2A1A200000010
STRUCT_POINTER_B = 0xB1B2B1B200000020
STRUCT_POINTER_C = 0xC1C2C1C200000030
STRUCT_POINTER_D = 0xD1D2D1D200000040

SINGLE_SEGMENT = IO::Buffer.for([
  0,     # Number of segments (minus one)
  1,     # Size of segment 0 (in words)
  16, 32 # Segment 0 (Contains a struct pointer)
].pack("L<*"))

FOUR_SEGMENT = IO::Buffer.for(
  # Message header
  [
    3, # Number of segments (minus one)
    7, # Size of segment 0 (in words)
    2, # Size of segment 1
    7, # Size of segment 2
    5, # Size of segment 3
    0  # Padding
  ].pack("L<*") +

  # Segment 0
  [
    build_far_pointer(true, 1, 0),   # 0+00: Single far pointer to 1+00 (STRUCT_POINTER_D)
    STRUCT_POINTER_A,                # 0+08
    build_far_pointer(true, 9, 0),   # 0+16: Single far pointer to 9+00 (Invalid segment)
    STRUCT_POINTER_B,                # 0+24
    build_far_pointer(true, 1, 32),  # 0+32: Single far pointer to 1+32 (Invalid offset)
    STRUCT_POINTER_C,                # 0+40
    build_far_pointer(false, 2, 0)   # 0+48: Double far pointer to 2+00 (Another double pointer)
  ].pack("Q<*") +

  # Segment 1
  [
    STRUCT_POINTER_D,                # 1+00
    build_far_pointer(true, 0, 8)    # 1+08: Single far pointer to 0+08 (STRUCT_POINTER_A)
  ].pack("Q<*") +

  # Segment 2
  [
    build_far_pointer(false, 0, 0),  # 2+00: Double far pointer to 0+00 (A single pointer)
    build_far_pointer(false, 8, 16), # 2+08: Double far pointer to 8+16 (Invalid segment)
    build_far_pointer(false, 1, 64), # 2+16: Double far pointer to 1+64 (Invalid offset)
    build_far_pointer(false, 1, 0),  # 2+24: Double far pointer to 1+00 (STRUCT_POINTER_D)
    build_far_pointer(false, 1, 8),  # 2+32: Double far pointer to 1+08 (Single pointer with a missing tag)
    build_far_pointer(false, 0, 16), # 2+40: Double far pointer to 0+16 (Single pointer with an invalid segment)
    build_far_pointer(false, 0, 32)  # 2+48: Double far pointer to 0+32 (Single pointer with an invalid offset)
  ].pack("Q<*") +

  # Segment 3
  [
    6456, 8378, 1337, 8954, 2724 # Random data
  ].pack("Q<*")
)

NOT_ENOUGH_SIZES = IO::Buffer.for([
  3, # Number of segments (minus one)
  1, # Size of segment 0 (in words)
  2 # Size of segment 1
  # MISSING
].pack("L<*"))

NOT_ENOUGH_DATA = IO::Buffer.for([
  0,    # Number of segments (minus one)
  9999,    # Size of segment 0 (in words)
  1234, # Segment 0
  5678
].pack("L<*"))

RSpec.describe CapnProto::Message do
  let(:single_segment) { described_class.from_buffer(SINGLE_SEGMENT) }
  let(:single_segments) { single_segment.instance_variable_get(:@segments) }
  let(:four_segment) { described_class.from_buffer(FOUR_SEGMENT) }
  let(:four_segments) { four_segment.instance_variable_get(:@segments) }

  describe ".from_buffer" do
    it "creates a new message from a buffer" do
      expect(single_segment).to be_a(described_class)
    end

    it "extracts the number of segments from the message" do
      expect(single_segments.length).to eq(1)
      expect(four_segment.instance_variable_get(:@segments).length).to eq(4)
    end

    it "creates segments of the correct sizes" do
      expect(single_segments[0].size).to eq(8)

      expect(four_segments[0].size).to eq(56)
      expect(four_segments[1].size).to eq(16)
      expect(four_segments[2].size).to eq(56)
      expect(four_segments[3].size).to eq(40)
    end

    it "creates segments with the correct offsets" do
      expect(single_segments[0].offset).to eq(8)

      expect(four_segments[0].offset).to eq(24)
      expect(four_segments[1].offset).to eq(80)
      expect(four_segments[2].offset).to eq(96)
      expect(four_segments[3].offset).to eq(152)
    end

    it "raises an error if the number of sizes does not match the number of segments" do
      expect { described_class.from_buffer(NOT_ENOUGH_SIZES) }
        .to raise_error("Not enough segment sizes provided")
    end

    it "raises an error if the buffer is too small for given segment sizes" do
      expect { described_class.from_buffer(NOT_ENOUGH_DATA) }
        .to raise_error("Buffer smaller than provided segment sizes")
    end
  end

  describe "#root" do
    it "returns a reference to the first pointer in the first segment" do
      message = described_class.from_buffer(FOUR_SEGMENT)

      # Get the root pointer
      root = message.root

      # Verify the root pointer
      expect(root.offset).to eq(24)
      expect(root.size).to eq(CapnProto::WORD_SIZE)
    end
  end

  describe "#dereference_pointer" do
    context "not a far pointer" do
      it "returns the original pointer" do
        # SINGLE_SEGMENT contains a struct pointer
        pointer = single_segment.root
        expect(single_segment.dereference_pointer(pointer)).to eq([pointer, nil])
      end
    end

    context "single far pointer" do
      it "dereferences a far pointer to a higher segment" do
        # 0+00: Single far pointer -> 1+00: STRUCT_POINTER_D
        pointer = four_segments[0].apply_offset(0, CapnProto::WORD_SIZE)
        ref, content = four_segment.dereference_pointer(pointer)
        expect(ref.read_integer(0, false, 64)).to eq(STRUCT_POINTER_D)
        expect(content).to be_nil
      end

      it "dereferences a far pointer to a lower segment" do
        # 1+08: Single far pointer -> 0+08: STRUCT_POINTER_A
        pointer = four_segments[1].apply_offset(8, CapnProto::WORD_SIZE)
        ref, content = four_segment.dereference_pointer(pointer)
        expect(ref.read_integer(0, false, 64)).to eq(STRUCT_POINTER_A)
        expect(content).to be_nil
      end

      it "raises an error if the segment ID is unknown" do
        # 0+16: Single far pointer -> 9+00: Invalid segment
        pointer = four_segments[0].apply_offset(16, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "Unknown segment ID 9 in far pointer")
      end

      it "raises an error if the offset is outside the targeted segment" do
        # 0+32: Single far pointer -> 1+32: Invalid offset
        pointer = four_segments[0].apply_offset(32, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "Invalid offset 32 for segment 1 in far pointer")
      end
    end

    context "double far pointer" do
      it "dereferences a far pointer to a higher segment" do
        # 2+00: Double far pointer -> 0+00: Single far pointer     -> 1+00: STRUCT_POINTER_D
        #                             0+08: Tag (STRUCT_POINTER_A)
        pointer = four_segments[2].apply_offset(0, CapnProto::WORD_SIZE)
        ref, content = four_segment.dereference_pointer(pointer)
        expect(ref.read_integer(0, false, 64)).to eq(STRUCT_POINTER_A)
        expect(content.read_integer(0, false, 64)).to eq(STRUCT_POINTER_D)
      end

      it "raises an error if the segment ID is unknown" do
        # 2+08: Double far pointer -> 8+16: Invalid segment
        pointer = four_segments[2].apply_offset(8, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "Unknown segment ID 8 in far pointer")
      end

      it "raises an error if the offset is outside the targeted segment" do
        # 2+16: Double far pointer -> 1+64: Invalid offset
        pointer = four_segments[2].apply_offset(16, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "Invalid offset 64 for segment 1 in far pointer")
      end

      it "raises an error if the nested far pointer is a double pointer" do
        # 0+48: Double far pointer -> 2+00: Double far pointer -> Error
        pointer = four_segments[0].apply_offset(48, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "Double far pointer pointing to another double far pointer")
      end

      it "raises an error if the first word is not a nested far pointer" do
        # 2+24: Double far pointer -> 1+00: STRUCT_POINTER_D
        pointer = four_segments[2].apply_offset(24, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "First word of double far pointer is not a far pointer")
      end

      it "raises an error if the second word is outside the segment" do
        # 2+32: Double far pointer -> 1+08: Single far pointer
        #                             1+16: Invalid offset
        pointer = four_segments[2].apply_offset(32, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "Invalid offset 8 for segment 1 in far pointer")
      end

      it "raises an error if the nested far pointer refers to an unknown segment" do
        # 2+40: Double far pointer -> 0+16: Single far pointer -> 9+00: Invalid segment
        #                             0+24: STRUCT_POINTER_B
        pointer = four_segments[2].apply_offset(40, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "Unknown segment ID 9 in far pointer")
      end

      it "raises an error if the nested far pointer refers to an offset outside the segment" do
        # 2+48: Double far pointer -> 0+32: Single far pointer -> 1+32: Invalid offset
        #                             0+40: STRUCT_POINTER_C
        pointer = four_segments[2].apply_offset(48, CapnProto::WORD_SIZE)
        expect { four_segment.dereference_pointer(pointer) }
          .to raise_error(CapnProto::Error, "Invalid offset 32 for segment 1 in far pointer")
      end
    end
  end
end
