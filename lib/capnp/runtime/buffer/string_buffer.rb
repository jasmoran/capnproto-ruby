# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "sliceable_buffer"

class Capnp::StringBuffer
  extend T::Sig

  include Capnp::SliceableBuffer

  sig { params(buffer: String).void }
  def initialize(buffer)
    @buffer = T.let(buffer.encode(Encoding::BINARY), String)
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
    raise Capnp::Error.new("Offset+length exceeds data size") if slice.nil? || slice.bytesize != length
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
end
