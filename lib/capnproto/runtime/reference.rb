# typed: strict
# frozen_string_literal: true

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
    CapnProto::Reference.new(CapnProto::IOBuffer.new(IO::Buffer.for("")).freeze, 0, 0...0).freeze,
    CapnProto::Reference
  )

  NULL_POINTER = T.let(
    CapnProto::Reference.new(CapnProto::IOBuffer.new(IO::Buffer.for("\x00\x00\x00\x00\x00\x00\x00\x00")).freeze, 0, 0...8).freeze,
    CapnProto::Reference
  )

  sig { returns(Integer) }
  attr_reader :position

  sig { returns(T::Range[Integer]) }
  attr_reader :bounds

  sig { overridable.params(offset: Integer).returns(CapnProto::Reference) }
  def offset_position(offset) = self.class.new(@buffer, @position + offset, @bounds)

  sig { params(offset: Integer, length: Integer).returns(String) }
  def read_string(offset, length)
    @buffer.read_string(@position + offset, length)
  end

  sig { params(offset: Integer, length: Integer).returns(String) }
  def read_bytes(offset, length)
    @buffer.read_bytes(@position + offset, length)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_u8(offset)
    @buffer.read_u8(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_u16(offset)
    @buffer.read_u16(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_u32(offset)
    @buffer.read_u32(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_u64(offset)
    @buffer.read_u64(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_s8(offset)
    @buffer.read_s8(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_s16(offset)
    @buffer.read_s16(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_s32(offset)
    @buffer.read_s32(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_s64(offset)
    @buffer.read_s64(@position + offset)
  end

  sig { params(offset: Integer).returns(Float) }
  def read_f32(offset)
    @buffer.read_f32(@position + offset)
  end

  sig { params(offset: Integer).returns(Float) }
  def read_f64(offset)
    @buffer.read_f64(@position + offset)
  end

  sig { returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer = @buffer.dereference_pointer(self)
end
