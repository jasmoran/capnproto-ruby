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

  sig { params(data: String).returns(CapnProto::Buffer) }
  def self.from_string(data) = new(IO::Buffer.for(data))

  sig { params(data: IO).returns(CapnProto::Buffer) }
  def self.from_io(data) = new(IO::Buffer.for(data.read))

  sig { params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding) = @buffer.get_string(@offset + offset, length, encoding)

  sig { params(offset: Integer, signed: T::Boolean, number_bits: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits)
    sign = number_bits == 8 ? (signed ? 'S' : 'U') : (signed ? 's' : 'u')
    type = :"#{sign}#{number_bits}"
    T.cast(@buffer.get_value(type, @offset + offset), Integer)
  end

  sig { params(offset: Integer, size: Integer).returns(CapnProto::Buffer) }
  def apply_offset(offset, size) = CapnProto::Buffer.new(@buffer, @offset + offset, size)

  sig { returns(String) }
  def hexdump = @buffer.slice(@offset, @size).hexdump
end
