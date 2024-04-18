# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

module Schema
  class CapnpVersion < CapnProto::Struct
    sig { returns(Integer) }
    def major = read_integer(0, false, 16, 0)

    sig { returns(Integer) }
    def minor = read_integer(2, false, 8, 0)

    sig { returns(Integer) }
    def micro = read_integer(3, false, 8, 0)

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      major: major,
      minor: minor,
      micro: micro,
    }
  end

  class CodeGeneratorRequest < CapnProto::Struct
    sig { returns(T.nilable(CapnpVersion)) }
    def capnpVersion = CapnpVersion.from_pointer(read_pointer(2))

    sig { returns(T.nilable(CapnProto::Data)) }
    def requestedFiles = CapnProto::Data.from_pointer(read_pointer(1))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      capnpVersion: capnpVersion.to_h,
      requestedFiles: requestedFiles,
    }

    class RequestedFile < CapnProto::Struct
      sig { returns(Integer) }
      def id = read_integer(0, false, 64, 0)

      sig { returns(T.nilable(CapnProto::String)) }
      def filename = CapnProto::String.from_pointer(read_pointer(0))

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h = {
        id: id,
        filename: filename&.value,
        imports: nil,
      }

      class Import < CapnProto::Struct
        sig { returns(Integer) }
        def id = read_integer(0, false, 64, 0)

        sig { returns(T.nilable(CapnProto::String)) }
        def name = CapnProto::String.from_pointer(read_pointer(0))

        sig { returns(T::Hash[Symbol, T.untyped]) }
        def to_h = {
          id: id,
          name: name&.value,
        }
      end
    end
  end
end
