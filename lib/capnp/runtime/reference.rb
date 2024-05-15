# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "buffer/buffer"

class Capnp::Reference
  extend T::Sig

  sig { params(segment: Capnp::Segment, position: Integer).void }
  def initialize(segment, position)
    @segment = segment
    @position = position
  end

  EMPTY = T.let(
    Capnp::Reference.new(
      Capnp::FlatMessage.new(Capnp::StringBuffer.new("")).segment(0),
      0
    ),
    Capnp::Reference
  )

  NULL_POINTER = T.let(
    Capnp::Reference.new(
      Capnp::FlatMessage.new(Capnp::StringBuffer.new("\x00\x00\x00\x00\x00\x00\x00\x00")).segment(0),
      0
    ),
    Capnp::Reference
  )

  sig { returns(Capnp::Segment) }
  attr_reader :segment

  sig { returns(Integer) }
  attr_reader :position

  sig { overridable.params(offset: Integer).returns(Capnp::Reference) }
  def offset_position(offset)
    self.class.new(@segment, @position + offset)
  end

  sig { params(offset: Integer, length: Integer).returns(String) }
  def read_string(offset, length)
    @segment.read_string(@position + offset, length)
  end

  sig { params(offset: Integer, length: Integer).returns(String) }
  def read_bytes(offset, length)
    @segment.read_bytes(@position + offset, length)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_u8(offset)
    @segment.read_u8(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_u16(offset)
    @segment.read_u16(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_u32(offset)
    @segment.read_u32(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_u64(offset)
    @segment.read_u64(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_s8(offset)
    @segment.read_s8(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_s16(offset)
    @segment.read_s16(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_s32(offset)
    @segment.read_s32(@position + offset)
  end

  sig { params(offset: Integer).returns(Integer) }
  def read_s64(offset)
    @segment.read_s64(@position + offset)
  end

  sig { params(offset: Integer).returns(Float) }
  def read_f32(offset)
    @segment.read_f32(@position + offset)
  end

  sig { params(offset: Integer).returns(Float) }
  def read_f64(offset)
    @segment.read_f64(@position + offset)
  end
end
