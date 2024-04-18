# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::Buffer
  extend T::Sig

  private_class_method :new

  sig { params(buffer: IO::Buffer, id: String).void }
  def initialize(buffer, id)
    @buffer = buffer
    @id = T.let(id, String)
  end

  sig { returns(String) }
  attr_reader :id

  sig { overridable.params(buffer: IO::Buffer, id: String).returns(T.attached_class) }
  def self.from_buffer(buffer, id) = new(buffer, id)

  sig { params(data: String, id: String).returns(T.attached_class) }
  def self.from_string(data, id) = from_buffer(IO::Buffer.for(data), id)

  sig { params(data: IO, id: String).returns(T.attached_class) }
  def self.from_io(data, id) = from_string(data.read, id)

  EMPTY = T.let(
    CapnProto::Buffer.from_string('', 'EMPTY').freeze,
    CapnProto::Buffer
  )

  NULL_POINTER = T.let(
    CapnProto::Buffer.from_string("\x00\x00\x00\x00\x00\x00\x00\x00", 'NULL_POINTER').freeze,
    CapnProto::Buffer
  )

  sig { params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding) = @buffer.get_string(offset, length, encoding)

  sig { params(offset: Integer, signed: T::Boolean, number_bits: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits)
    sign = number_bits == 8 ? (signed ? 'S' : 'U') : (signed ? 's' : 'u')
    type = :"#{sign}#{number_bits}"
    T.cast(@buffer.get_value(type, offset), Integer)
  end

  sig { returns(String) }
  def hexdump = @buffer.hexdump

  sig { overridable.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
    pointer_type = pointer_ref.read_integer(0, false, 8) & 0b11
    raise 'Far pointers not supported on Buffer type, use Message' if pointer_type == 2
    return pointer_ref, nil
  end
end
