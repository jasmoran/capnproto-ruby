# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'
require_relative 'buffer'

class CapnProto::Reference
  extend T::Sig

  sig { params(buffer: CapnProto::Buffer, offset: Integer, size: Integer).void }
  def initialize(buffer, offset, size)
    @buffer = buffer
    @offset = offset
    @size = size
  end

  EMPTY = T.let(
    CapnProto::Reference.new(CapnProto::Buffer::EMPTY, 0, 0).freeze,
    CapnProto::Reference
  )

  NULL_POINTER = T.let(
    CapnProto::Reference.new(CapnProto::Buffer::NULL_POINTER, 0, 8).freeze,
    CapnProto::Reference
  )

  sig { returns(Integer) }
  attr_reader :size

  sig { overridable.params(offset: Integer, size: Integer).returns(CapnProto::Reference) }
  def apply_offset(offset, size) = self.class.new(@buffer, @offset + offset, size)

  sig { params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding) = @buffer.read_string(@offset + offset, length, encoding)

  sig { params(offset: Integer, signed: T::Boolean, number_bits: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits) = @buffer.read_integer(@offset + offset, signed, number_bits)
end
