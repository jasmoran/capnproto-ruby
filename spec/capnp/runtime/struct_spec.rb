# typed: strong
# frozen_string_literal: true

require "tempfile"
require_relative "../../spec_helper"
require_relative "message_helper"

class TestStruct < Capnp::Struct
  sig { returns(Integer) }
  attr_reader :data_size, :pointers_size

  sig { returns(Capnp::Reference) }
  attr_reader :data, :pointers

  sig { override.returns(Object) }
  def to_obj
    nil
  end

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def _read_u8(offset, default) = read_u8(offset, default)
  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def _read_u16(offset, default) = read_u16(offset, default)
  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def _read_u32(offset, default) = read_u32(offset, default)
  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def _read_u64(offset, default) = read_u64(offset, default)
  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def _read_s8(offset, default) = read_s8(offset, default)
  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def _read_s16(offset, default) = read_s16(offset, default)
  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def _read_s32(offset, default) = read_s32(offset, default)
  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def _read_s64(offset, default) = read_s64(offset, default)
  sig { params(offset: Integer, default: Float).returns(Float) }
  def _read_f32(offset, default) = read_f32(offset, default)
  sig { params(offset: Integer, default: Float).returns(Float) }
  def _read_f64(offset, default) = read_f64(offset, default)
  sig { params(ix: Integer).returns(Capnp::Reference) }
  def _read_pointer(ix) = read_pointer(ix)
end

describe Capnp::Struct, nil do
  describe ".decode_pointer" do
    it "returns all zeroes for a NULL pointer" do
      offset_words, data_words, pointers_words = Capnp::Struct.decode_pointer(Capnp::Reference::NULL_POINTER)
      expect(offset_words).must_equal(0)
      expect(data_words).must_equal(0)
      expect(pointers_words).must_equal(0)
    end

    it "handles positive offset_words" do
      buffer = Capnp::StringBuffer.new("\x20\x00\x00\x00\x07\x00\x05\x00".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      offset_words, _, _ = Capnp::Struct.decode_pointer(pointer)
      expect(offset_words).must_equal(8)
    end

    it "handles negative offset_words" do
      buffer = Capnp::StringBuffer.new("\xF4\xFF\xFF\xFF\x00\x30\x00\x09".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      offset_words, _, _ = Capnp::Struct.decode_pointer(pointer)
      expect(offset_words).must_equal(-3)
    end

    it "handles large data_words as unsigned" do
      buffer = Capnp::StringBuffer.new("\x00\x00\x00\x00\xFF\xFF\x00\x00".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      _, data_words, _ = Capnp::Struct.decode_pointer(pointer)
      expect(data_words).must_equal(0xFFFF)
    end

    it "handles large pointers_words as unsigned" do
      buffer = Capnp::StringBuffer.new("\x00\x00\x00\x00\x00\x00\xFF\xFF".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      _, _, pointers_words = Capnp::Struct.decode_pointer(pointer)
      expect(pointers_words).must_equal(0xFFFF)
    end

    it "errors if buffer too small" do
      expect { Capnp::Struct.decode_pointer(Capnp::Reference::EMPTY) }.must_raise
    end

    it "errors on non-struct pointer" do
      buffer = Capnp::StringBuffer.new("\x01\x00\x00\x00\x00\x00\x00\x00".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      expect { Capnp::Struct.decode_pointer(pointer) }.must_raise(Capnp::Error, "Pointer has type 1")
    end
  end

  describe ".from_pointer" do
    it "returns nil for a NULL pointer" do
      expect(Capnp::Struct.from_pointer(Capnp::Reference::NULL_POINTER)).must_be_nil
    end

    it "returns an empty struct when offset is -1" do
      buffer = Capnp::StringBuffer.new("\xFC\xFF\xFF\xFF\x00\x00\x00\x00".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      struct = TestStruct.from_pointer(pointer)
      expect(struct&.data_size).must_equal(0)
      expect(struct&.pointers_size).must_equal(0)
    end

    it "extracts data size" do
      buffer = Capnp::StringBuffer.new("\x00\x00\x00\x00\x03\x00\x00\x00".b + "\x00" * 24)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      struct = TestStruct.from_pointer(pointer)
      expect(struct&.data_size).must_equal(24)
    end

    it "calculates data offset in segment" do
      buffer = Capnp::StringBuffer.new("\x10\x00\x00\x00\x01\x00\x00\x00".b + "\x00" * 40)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      struct = TestStruct.from_pointer(pointer)
      expect(struct&.data&.position).must_equal(40)
    end

    it "extracts pointers size" do
      buffer = Capnp::StringBuffer.new("\x00\x00\x00\x00\x00\x00\x05\x00".b + "\x00" * 40)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      struct = TestStruct.from_pointer(pointer)
      expect(struct&.pointers_size).must_equal(40)
    end

    it "calculates pointers offset in segment" do
      buffer = Capnp::StringBuffer.new("\x00" * 32 + "\xF4\xFF\xFF\xFF\x01\x00\x01\x00".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 32)
      struct = TestStruct.from_pointer(pointer)
      expect(struct&.data&.position).must_equal(16)
      expect(struct&.pointers&.position).must_equal(24)
    end

    it "throws an error if buffer is too small for content" do
      buffer = Capnp::StringBuffer.new("\x00\x00\x00\x00\x00\x00\x05\x00".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 0)
      expect { TestStruct.from_pointer(pointer) }.must_raise(Capnp::Error, "Buffer too small for Struct content")
    end

    it "throws an error if content overlaps the pointer" do
      buffer = Capnp::StringBuffer.new("\x00" * 32 + "\xF4\xFF\xFF\xFF\x02\x00\x01\x00".b)
      segment = Capnp::FlatMessage.new(buffer).segment(0)
      pointer = Capnp::Reference.new(segment, 32)
      expect { TestStruct.from_pointer(pointer) }.must_raise(Capnp::Error, "Struct content overlaps pointer")
    end

    it "follows far pointers" do
      message = MessageHelper.four_segment
      pointer = message.segment(2).to_reference
      struct = TestStruct.from_pointer(pointer)
      expect(struct&.data&.segment).must_equal(message.segment(1))
      expect(struct&.data&.position).must_equal(0)
      expect(struct&.data_size).must_equal(8)
      expect(struct&.pointers&.segment).must_equal(message.segment(1))
      expect(struct&.pointers&.position).must_equal(8)
      expect(struct&.pointers_size).must_equal(8)
    end
  end

  describe "#read_pointer" do
    it "returns reference to the desired pointer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b * 2)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 0, reference, 16)
      expect(struct._read_pointer(1).position).must_equal(8)
    end

    it "returns NULL pointer if index out of range" do
      struct = TestStruct.new(Capnp::Reference::EMPTY, 0, Capnp::Reference::EMPTY, 0)
      expect(struct._read_pointer(9)).must_equal(Capnp::Reference::NULL_POINTER)
    end
  end

  describe "#read_u8" do
    it "reads integer from buffer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_u8(0, 0xF0)).must_equal(0x07)
    end

    it "returns default if offset outside data area" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_u8(9, 0xAB)).must_equal(0xAB)
    end
  end

  describe "#read_u16" do
    it "reads integer from buffer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_u16(0, 0xF007)).must_equal(0x06F0)
    end

    it "returns default if offset outside data area" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_u16(9, 0xABCD)).must_equal(0xABCD)
    end
  end

  describe "#read_u32" do
    it "reads integer from buffer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_u32(0, 0xFFFFFFFF)).must_equal(0x0B0A0908)
    end

    it "returns default if offset outside data area" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_u32(9, 0x89ABCDEF)).must_equal(0x89ABCDEF)
    end
  end

  describe "#read_u64" do
    it "reads integer from buffer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_u64(0, 0x0001020304050607)).must_equal(0xF0F0F0F0F0F0F0F0)
    end

    it "returns default if offset outside data area" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_u64(9, 0x0123456789ABCDEF)).must_equal(0x0123456789ABCDEF)
    end
  end

  describe "#read_s8" do
    it "reads integer from buffer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_s8(0, 0xF0)).must_equal(-249)
    end

    it "returns default if offset outside data area" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_s8(9, -222)).must_equal(-222)
    end
  end

  describe "#read_s16" do
    it "reads integer from buffer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_s16(0, 0xF007)).must_equal(-63760)
    end

    it "returns default if offset outside data area" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_s16(9, -63333)).must_equal(-63333)
    end
  end

  describe "#read_s32" do
    it "reads integer from buffer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_s32(0, 0xFFFFFFFF)).must_equal(-4109760248)
    end

    it "returns default if offset outside data area" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_s32(9, -4100000000)).must_equal(-4100000000)
    end
  end

  describe "#read_s64" do
    it "reads integer from buffer" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_s64(0, 0x0001020304050607)).must_equal(-1085102592571150096)
    end

    it "returns default if offset outside data area" do
      buffer = Capnp::StringBuffer.new("\xF7\xF6\xF5\xF4\xF3\xF2\xF1\xF0".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_s64(9, -1000000000000000000)).must_equal(-1000000000000000000)
    end
  end

  describe "#read_f32" do
    it "reads integer from buffer" do
      data = T.let([521.125].pack("e"), String)
      buffer = Capnp::StringBuffer.new(data + "\x00" * 8)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_f32(0, 0.0)).must_equal(521.125)
    end

    it "XORs buffer value with default float" do
      # High bit in buffer will flip sign bit in float
      buffer = Capnp::StringBuffer.new("\x00\x00\x00\x80".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_f32(0, -521.125)).must_equal(521.125)
    end

    it "returns default if offset outside data area" do
      struct = TestStruct.new(Capnp::Reference::NULL_POINTER, 8, Capnp::Reference::NULL_POINTER, 0)
      expect(struct._read_f32(9, 521.125)).must_equal(521.125)
    end
  end

  describe "#read_f64" do
    it "reads integer from buffer" do
      data = T.let([123.4].pack("E"), String)
      buffer = Capnp::StringBuffer.new(data + "\x00" * 8)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_f64(0, 0.0)).must_equal(123.4)
    end

    it "XORs buffer value with default float" do
      # High bit in buffer will flip sign bit in float
      buffer = Capnp::StringBuffer.new("\x00\x00\x00\x00\x00\x00\x00\x80".b)
      reference = Capnp::FlatMessage.new(buffer).segment(0).to_reference
      struct = TestStruct.new(reference, 8, reference, 0)
      expect(struct._read_f64(0, -123.4)).must_equal(123.4)
    end

    it "returns default if offset outside data area" do
      struct = TestStruct.new(Capnp::Reference::NULL_POINTER, 8, Capnp::Reference::NULL_POINTER, 0)
      expect(struct._read_f64(9, 123.4)).must_equal(123.4)
    end
  end
end
