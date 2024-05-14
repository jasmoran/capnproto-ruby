# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "sliceable_buffer"

class CapnProto::IOBuffer
  extend T::Sig
  include CapnProto::SliceableBuffer

  sig { params(buffer: IO::Buffer).void }
  def initialize(buffer)
    @buffer = buffer
  end

  sig { override.params(offset: Integer, length: Integer).returns(T.self_type) }
  def slice(offset, length)
    self.class.new(@buffer.slice(offset, length))
  end

  sig { override.params(offset: Integer, length: Integer).returns(String) }
  def read_string(offset, length)
    @buffer.get_string(offset, length, Encoding::UTF_8)
  end

  sig { override.params(offset: Integer, length: Integer).returns(String) }
  def read_bytes(offset, length)
    @buffer.get_string(offset, length, Encoding::BINARY)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u8(offset)
    T.cast(@buffer.get_value(:U8, offset), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u16(offset)
    T.cast(@buffer.get_value(:u16, offset), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u32(offset)
    T.cast(@buffer.get_value(:u32, offset), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u64(offset)
    T.cast(@buffer.get_value(:u64, offset), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s8(offset)
    T.cast(@buffer.get_value(:S8, offset), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s16(offset)
    T.cast(@buffer.get_value(:s16, offset), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s32(offset)
    T.cast(@buffer.get_value(:s32, offset), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s64(offset)
    T.cast(@buffer.get_value(:s64, offset), Integer)
  end

  sig { override.params(offset: Integer).returns(Float) }
  def read_f32(offset)
    T.cast(@buffer.get_value(:f32, offset), Float)
  end

  sig { override.params(offset: Integer).returns(Float) }
  def read_f64(offset)
    T.cast(@buffer.get_value(:f64, offset), Float)
  end

  sig { override.returns(Integer) }
  def size
    @buffer.size
  end

  sig { override.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
    pointer_type = pointer_ref.read_u8(0) & 0b11
    raise CapnProto::Error.new("Far pointers not supported on Buffer type, use Message") if pointer_type == 2
    [pointer_ref, nil]
  end
end
