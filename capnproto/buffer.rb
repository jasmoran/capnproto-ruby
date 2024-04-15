# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::Buffer
  extend T::Sig

  sig { params(buffer: IO::Buffer, offset: Integer, size: Integer).void }
  def initialize(buffer, offset = 0, size = buffer.size)
    @buffer = buffer
    @offset = offset
    @size = size
  end

  sig { returns(Integer) }
  attr_reader :size

  EMPTY = T.let(
    CapnProto::Buffer.new(IO::Buffer.for(''), 0, 0).freeze,
    CapnProto::Buffer
  )

  NULL_POINTER = T.let(
    CapnProto::Buffer.new(IO::Buffer.for("\x00\x00\x00\x00\x00\x00\x00\x00"), 0, 8).freeze,
    CapnProto::Buffer
  )

  sig { params(data: String).returns(T.attached_class) }
  def self.from_string(data) = self.new(IO::Buffer.for(data))

  sig { params(data: IO).returns(T.attached_class) }
  def self.from_io(data) = self.new(IO::Buffer.for(data.read))

  sig { params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding) = @buffer.get_string(@offset + offset, length, encoding)

  sig { params(offset: Integer, signed: T::Boolean, number_bits: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits)
    sign = number_bits == 8 ? (signed ? 'S' : 'U') : (signed ? 's' : 'u')
    type = :"#{sign}#{number_bits}"
    T.cast(@buffer.get_value(type, @offset + offset), Integer)
  end

  sig { params(offset: Integer, size: Integer).returns(T.self_type) }
  def apply_offset(offset, size) = self.class.new(@buffer, @offset + offset, size)

  sig { returns(String) }
  def hexdump = @buffer.slice(@offset, @size).hexdump
end
