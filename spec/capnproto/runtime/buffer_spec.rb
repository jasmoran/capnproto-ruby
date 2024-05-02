# typed: false
# frozen_string_literal: true

require "tempfile"

HELLO_HEXDUMP = "0x00000000  68 65 6c 6c 6f                                  hello"

RSpec.describe CapnProto::Buffer do
  describe ".from_buffer" do
    let(:io_buffer) { IO::Buffer.for("hello") }
    let(:buffer) { described_class.from_buffer(io_buffer) }

    it "returns a new instance of CapnProto::Buffer" do
      expect(buffer).to be_a(described_class)
    end

    it "sets the buffer data to 'hello'" do
      expect(buffer.hexdump).to eq(HELLO_HEXDUMP)
    end
  end

  describe ".from_string" do
    let(:buffer) { described_class.from_string("hello") }

    it "returns a new instance of CapnProto::Buffer" do
      expect(buffer).to be_a(described_class)
    end

    it "sets the buffer data to 'hello'" do
      expect(buffer.hexdump).to eq(HELLO_HEXDUMP)
    end
  end

  describe ".from_io" do
    let(:tempfile) do
      tf = Tempfile.create
      tf.write("hello")
      tf.rewind
      tf
    end
    after { File.unlink(tempfile.path) }
    let(:buffer) { described_class.from_io(tempfile) }

    it "returns a new instance of CapnProto::Buffer" do
      expect(buffer).to be_a(described_class)
    end

    it "sets the buffer data to 'hello'" do
      expect(buffer.hexdump).to eq(HELLO_HEXDUMP)
    end
  end

  describe "#read_string" do
    let(:buffer) { described_class.from_string("hello") }

    it "reads a string from the buffer" do
      expect(buffer.read_string(0, 5, Encoding::UTF_8)).to eq("hello")
    end

    it "raises an error if the offset is outside the buffer" do
      expect { buffer.read_string(6, 1, Encoding::UTF_8) }
        .to raise_error(ArgumentError, "Specified offset+length exceeds data size!")
    end

    it "raises an error if the length is too long" do
      expect { buffer.read_string(0, 6, Encoding::UTF_8) }
        .to raise_error(ArgumentError, "Specified offset+length exceeds data size!")
    end
  end

  describe "#read_integer" do
    let(:buffer) { described_class.from_string("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0") }

    it "reads a U8 integer from the buffer" do
      expect(buffer.read_integer(0, false, 8)).to eq(0xF7)
    end

    it "reads a U16 integer from the buffer" do
      expect(buffer.read_integer(0, false, 16)).to eq(0xF6F7)
    end

    it "reads a U32 integer from the buffer" do
      expect(buffer.read_integer(0, false, 32)).to eq(0xF4F5F6F7)
    end

    it "reads a U64 integer from the buffer" do
      expect(buffer.read_integer(0, false, 64)).to eq(0xF0F1F2F3F4F5F6F7)
    end

    it "reads an S8 integer from the buffer" do
      expect(buffer.read_integer(0, true, 8)).to eq(-9)
    end

    it "reads an S16 integer from the buffer" do
      expect(buffer.read_integer(0, true, 16)).to eq(-2313)
    end

    it "reads an S32 integer from the buffer" do
      expect(buffer.read_integer(0, true, 32)).to eq(-185207049)
    end

    it "reads an S64 integer from the buffer" do
      expect(buffer.read_integer(0, true, 64)).to eq(-1084818905618843913)
    end

    it "raises an error if the offset is outside the buffer" do
      expect { buffer.read_integer(10, false, 8) }
        .to raise_error(ArgumentError, "Type extends beyond end of buffer!")
    end

    it "raises an error if the number of bits is invalid" do
      expect { buffer.read_integer(0, false, 7) }
        .to raise_error(ArgumentError, "Invalid type name!")
    end
  end

  describe "#read_float" do
    it "reads a float from the buffer" do
      buffer = described_class.from_string([521.125].pack("e"))
      expect(buffer.read_float(0, 32)).to eq(521.125)
    end

    it "reads a double from the buffer" do
      buffer = described_class.from_string([123.4].pack("E"))
      expect(buffer.read_float(0, 64)).to eq(123.4)
    end

    it "raises an error if the offset is outside the buffer" do
      expect { described_class::EMPTY.read_float(10, 64) }
        .to raise_error(ArgumentError, "Type extends beyond end of buffer!")
    end

    it "raises an error if the number of bits is invalid" do
      expect { described_class::EMPTY.read_float(0, 7) }
        .to raise_error(ArgumentError, "Invalid type name!")
    end
  end

  describe "#dereference_pointer" do
    let(:buffer) { described_class.from_string("\x00\x81\xF2") }
    let(:struct_pointer) { CapnProto::Reference.new(buffer, 0, 1, 0...3) }
    let(:list_pointer) { CapnProto::Reference.new(buffer, 1, 1, 0...3) }
    let(:far_pointer) { CapnProto::Reference.new(buffer, 2, 1, 0...3) }

    it "returns the reference if it is a null pointer" do
      expect(buffer.dereference_pointer(CapnProto::Reference::NULL_POINTER))
        .to eq([CapnProto::Reference::NULL_POINTER, nil])
    end

    it "returns the reference if it is a struct pointer" do
      expect(buffer.dereference_pointer(struct_pointer)).to eq([struct_pointer, nil])
    end

    it "returns the reference if it is a list pointer" do
      expect(buffer.dereference_pointer(list_pointer)).to eq([list_pointer, nil])
    end

    it "raises an error if the reference is a far pointer" do
      expect { buffer.dereference_pointer(far_pointer) }
        .to raise_error(CapnProto::Error, "Far pointers not supported on Buffer type, use Message")
    end
  end
end
