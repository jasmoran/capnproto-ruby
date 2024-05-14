# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "sliceable_buffer"

class CapnProto::StringBuffer
  extend T::Sig

  include CapnProto::SliceableBuffer

  sig { params(buffer: String).void }
  def initialize(buffer)
    @buffer = T.let(buffer.force_encoding(Encoding::BINARY), String)
  end

  sig { override.params(offset: Integer, length: Integer).returns(T.self_type) }
  def slice(offset, length)
    self.class.new(read_bytes(offset, length))
  end

  sig { override.returns(Integer) }
  def size
    @buffer.bytesize
  end

  sig { override.params(offset: Integer, length: Integer).returns(String) }
  def read_string(offset, length)
    read_bytes(offset, length).encode!(Encoding::UTF_8)
  end

  sig { override.params(offset: Integer, length: Integer).returns(String) }
  def read_bytes(offset, length)
    slice = @buffer.byteslice(offset, length)
    raise CapnProto::Error.new("Offset+length exceeds data size") if slice.nil? || slice.bytesize != length
    slice
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u8(offset)
    T.cast(read_bytes(offset, 1).unpack1("C"), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u16(offset)
    T.cast(read_bytes(offset, 2).unpack1("S<"), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u32(offset)
    T.cast(read_bytes(offset, 4).unpack1("L<"), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_u64(offset)
    T.cast(read_bytes(offset, 8).unpack1("Q<"), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s8(offset)
    T.cast(read_bytes(offset, 1).unpack1("c"), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s16(offset)
    T.cast(read_bytes(offset, 2).unpack1("s<"), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s32(offset)
    T.cast(read_bytes(offset, 4).unpack1("l<"), Integer)
  end

  sig { override.params(offset: Integer).returns(Integer) }
  def read_s64(offset)
    T.cast(read_bytes(offset, 8).unpack1("q<"), Integer)
  end

  sig { override.params(offset: Integer).returns(Float) }
  def read_f32(offset)
    T.cast(read_bytes(offset, 4).unpack1("e"), Float)
  end

  sig { override.params(offset: Integer).returns(Float) }
  def read_f64(offset)
    T.cast(read_bytes(offset, 8).unpack1("E"), Float)
  end

  sig { override.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
    pointer_type = pointer_ref.read_u8(0) & 0b11
    raise CapnProto::Error.new("Far pointers not supported on Buffer type, use Message") if pointer_type == 2
    [pointer_ref, nil]
  end
end
