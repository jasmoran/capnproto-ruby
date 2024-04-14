# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

module Schema
  class CapnpVersion < CapnProto::StructPointer
    sig { returns(Integer) }
    def major = read_integer(0, :u16)

    sig { returns(Integer) }
    def minor = read_integer(2, :U8)

    sig { returns(Integer) }
    def micro = read_integer(3, :U8)

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      major: major,
      minor: minor,
      micro: micro,
    }
  end

  class CodeGeneratorRequest < CapnProto::StructPointer
    sig { returns(CapnpVersion) }
    def capnpVersion = CapnpVersion.new(@segment, pointer_offset(2))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      capnpVersion: capnpVersion.to_h,
    }
  end
end
