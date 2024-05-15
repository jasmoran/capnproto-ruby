# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"

module Capnp::Buffer
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.params(offset: Integer, length: Integer).returns(String) }
  def read_string(offset, length)
  end

  sig { abstract.params(offset: Integer, length: Integer).returns(String) }
  def read_bytes(offset, length)
  end

  sig { abstract.params(offset: Integer).returns(Integer) }
  def read_u8(offset)
  end

  sig { abstract.params(offset: Integer).returns(Integer) }
  def read_u16(offset)
  end

  sig { abstract.params(offset: Integer).returns(Integer) }
  def read_u32(offset)
  end

  sig { abstract.params(offset: Integer).returns(Integer) }
  def read_u64(offset)
  end

  sig { abstract.params(offset: Integer).returns(Integer) }
  def read_s8(offset)
  end

  sig { abstract.params(offset: Integer).returns(Integer) }
  def read_s16(offset)
  end

  sig { abstract.params(offset: Integer).returns(Integer) }
  def read_s32(offset)
  end

  sig { abstract.params(offset: Integer).returns(Integer) }
  def read_s64(offset)
  end

  sig { abstract.params(offset: Integer).returns(Float) }
  def read_f32(offset)
  end

  sig { abstract.params(offset: Integer).returns(Float) }
  def read_f64(offset)
  end

  sig { abstract.returns(Integer) }
  def size
  end
end
