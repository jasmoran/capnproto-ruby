# typed: strict

require "sorbet-runtime"
require_relative "buffer"

class CapnProto::Reference
  extend T::Sig

  sig { params(buffer: CapnProto::Buffer, position: Integer, bounds: T::Range[Integer]).void }
  def initialize(buffer, position, bounds)
    @buffer = buffer
    @position = position
    @bounds = bounds
  end

  EMPTY = T.let(
    CapnProto::Reference.new(CapnProto::IOBuffer::EMPTY, 0, 0...0).freeze,
    CapnProto::Reference
  )

  NULL_POINTER = T.let(
    CapnProto::Reference.new(CapnProto::IOBuffer::NULL_POINTER, 0, 0...8).freeze,
    CapnProto::Reference
  )

  sig { returns(Integer) }
  attr_reader :position

  sig { returns(T::Range[Integer]) }
  attr_reader :bounds

  sig { overridable.params(offset: Integer).returns(CapnProto::Reference) }
  def offset_position(offset) = self.class.new(@buffer, @position + offset, @bounds)

  sig { params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding) = @buffer.read_string(@position + offset, length, encoding)

  sig { params(offset: Integer, signed: T::Boolean, number_bits: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits) = @buffer.read_integer(@position + offset, signed, number_bits)

  sig { params(offset: Integer, number_bits: Integer).returns(Float) }
  def read_float(offset, number_bits) = @buffer.read_float(@position + offset, number_bits)

  sig { returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer = @buffer.dereference_pointer(self)
end
