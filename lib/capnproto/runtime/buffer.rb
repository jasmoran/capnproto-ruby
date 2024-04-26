# typed: strict

require "sorbet-runtime"
require_relative "capnproto"

class CapnProto::Buffer
  extend T::Sig

  private_class_method :new

  sig { params(buffer: IO::Buffer).void }
  def initialize(buffer)
    @buffer = buffer
  end

  sig { overridable.params(buffer: IO::Buffer).returns(T.attached_class) }
  def self.from_buffer(buffer) = new(buffer)

  sig { params(data: String).returns(T.attached_class) }
  def self.from_string(data) = from_buffer(IO::Buffer.for(data))

  sig { params(data: IO).returns(T.attached_class) }
  def self.from_io(data) = from_string(data.read)

  EMPTY = T.let(
    CapnProto::Buffer.from_string("").freeze,
    CapnProto::Buffer
  )

  NULL_POINTER = T.let(
    CapnProto::Buffer.from_string("\x00\x00\x00\x00\x00\x00\x00\x00").freeze,
    CapnProto::Buffer
  )

  sig { params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding) = @buffer.get_string(offset, length, encoding)

  sig { params(offset: Integer, signed: T::Boolean, number_bits: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits)
    sign = if number_bits == 8
      signed ? "S" : "U"
    else
      (signed ? "s" : "u")
    end
    type = :"#{sign}#{number_bits}"
    T.cast(@buffer.get_value(type, offset), Integer)
  end

  sig { params(offset: Integer, number_bits: Integer).returns(Float) }
  def read_float(offset, number_bits)
    type = :"f#{number_bits}"
    T.cast(@buffer.get_value(type, offset), Float)
  end

  sig { returns(String) }
  def hexdump = @buffer.hexdump

  sig { overridable.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
    pointer_type = pointer_ref.read_integer(0, false, 8) & 0b11
    raise "Far pointers not supported on Buffer type, use Message" if pointer_type == 2
    [pointer_ref, nil]
  end
end