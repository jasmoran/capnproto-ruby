# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"

class CapnProto::Segment
  extend T::Sig

  include CapnProto::Buffer

  sig { params(message: CapnProto::Message, buffer: CapnProto::Buffer).void }
  def initialize(message, buffer)
    @message = message
    @buffer = buffer
  end

  sig { returns(CapnProto::Message) }
  attr_reader :message

  sig { override.params(offset: Integer, length: Integer).returns(String) }
  def read_string(offset, length)
    @buffer.read_string(offset, length)
  end

  sig { override.params(offset: Integer, length: Integer).returns(String) }
  def read_bytes(offset, length)
    @buffer.read_bytes(offset, length)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u8(offset)
    @buffer.read_u8(offset)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u16(offset)
    @buffer.read_u16(offset)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u32(offset)
    @buffer.read_u32(offset)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u64(offset)
    @buffer.read_u64(offset)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s8(offset)
    @buffer.read_s8(offset)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s16(offset)
    @buffer.read_s16(offset)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s32(offset)
    @buffer.read_s32(offset)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s64(offset)
    @buffer.read_s64(offset)
  end

  sig { override.params(offset: Integer).returns(Float) }
  def read_f32(offset)
    @buffer.read_f32(offset)
  end

  sig { override.params(offset: Integer).returns(Float) }
  def read_f64(offset)
    @buffer.read_f64(offset)
  end

  sig { override.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
    @message.dereference_pointer(pointer_ref)
  end

  sig { override.returns(Integer) }
  def size
    @buffer.size
  end

  sig { returns(CapnProto::Reference) }
  def to_reference
    CapnProto::Reference.new(self, 0, 0...size)
  end
end
