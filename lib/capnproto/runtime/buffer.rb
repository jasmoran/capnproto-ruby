# typed: strong

require "sorbet-runtime"

module CapnProto::Buffer
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding)
  end

  sig { abstract.params(offset: Integer, signed: T::Boolean, number_bits: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits)
  end

  sig { abstract.params(offset: Integer, number_bits: Integer).returns(Float) }
  def read_float(offset, number_bits)
  end

  sig { abstract.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
  end
end
