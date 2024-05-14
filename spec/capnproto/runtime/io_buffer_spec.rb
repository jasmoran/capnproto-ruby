# typed: strong
# frozen_string_literal: true

require "tempfile"
require_relative "../../spec_helper"

HELLO_HEXDUMP = "0x00000000  68 65 6c 6c 6f                                  hello"

describe CapnProto::IOBuffer, nil do
  describe ".new" do
    it "returns a new instance of CapnProto::IOBuffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("hello"))
      expect(buffer).must_be_instance_of(CapnProto::IOBuffer)
    end
  end

  describe "#read_string" do
    it "reads a string from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("hello"))
      expect(buffer.read_string(0, 5)).must_equal("hello")
    end

    it "raises an error if the offset is outside the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("hello"))
      expect { buffer.read_string(6, 1) }
        .must_raise(ArgumentError, "Specified offset+length exceeds data size!")
    end

    it "raises an error if the length is too long" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("hello"))
      expect { buffer.read_string(0, 6) }
        .must_raise(ArgumentError, "Specified offset+length exceeds data size!")
    end
  end

  describe "#read_integer" do
    it "reads a U8 integer from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect(buffer.read_u8(0)).must_equal(0xF7)
    end

    it "reads a U16 integer from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect(buffer.read_u16(0)).must_equal(0xF6F7)
    end

    it "reads a U32 integer from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect(buffer.read_u32(0)).must_equal(0xF4F5F6F7)
    end

    it "reads a U64 integer from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect(buffer.read_u64(0)).must_equal(0xF0F1F2F3F4F5F6F7)
    end

    it "reads an S8 integer from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect(buffer.read_s8(0)).must_equal(-9)
    end

    it "reads an S16 integer from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect(buffer.read_s16(0)).must_equal(-2313)
    end

    it "reads an S32 integer from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect(buffer.read_s32(0)).must_equal(-185207049)
    end

    it "reads an S64 integer from the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect(buffer.read_s64(0)).must_equal(-1084818905618843913)
    end

    it "raises an error if the offset is outside the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0"))
      expect { buffer.read_u8(10) }
        .must_raise(ArgumentError, "Type extends beyond end of buffer!")
    end
  end

  describe "#read_float" do
    it "reads a float from the buffer" do
      data = T.let([521.125].pack("e"), String)
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for(data))
      expect(buffer.read_f32(0)).must_equal(521.125)
    end

    it "reads a double from the buffer" do
      data = T.let([123.4].pack("E"), String)
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for(data))
      expect(buffer.read_f64(0)).must_equal(123.4)
    end

    it "raises an error if the offset is outside the buffer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for(""))
      expect { buffer.read_f64(10) }
        .must_raise(ArgumentError, "Type extends beyond end of buffer!")
    end
  end

  describe "#dereference_pointer" do
    it "returns the reference if it is a null pointer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\x00\x81\xF2"))
      expect(buffer.dereference_pointer(CapnProto::Reference::NULL_POINTER))
        .must_equal([CapnProto::Reference::NULL_POINTER, nil])
    end

    it "returns the reference if it is a struct pointer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\x00\x81\xF2"))
      message = CapnProto::FlatMessage.new(buffer)
      struct_pointer = CapnProto::Reference.new(message.segment(0), 0)
      expect(buffer.dereference_pointer(struct_pointer)).must_equal([struct_pointer, nil])
    end

    it "returns the reference if it is a list pointer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\x00\x81\xF2"))
      message = CapnProto::FlatMessage.new(buffer)
      list_pointer = CapnProto::Reference.new(message.segment(0), 1)
      expect(buffer.dereference_pointer(list_pointer)).must_equal([list_pointer, nil])
    end

    it "raises an error if the reference is a far pointer" do
      buffer = CapnProto::IOBuffer.new(IO::Buffer.for("\x00\x81\xF2"))
      message = CapnProto::FlatMessage.new(buffer)
      far_pointer = CapnProto::Reference.new(message.segment(0), 2)
      expect { buffer.dereference_pointer(far_pointer) }
        .must_raise(CapnProto::Error, "Far pointers not supported on Buffer type, use Message")
    end
  end
end
