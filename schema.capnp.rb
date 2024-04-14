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

    sig { returns(T::Array[Integer]) }
    def requestedFiles
      pointer = CapnProto::ListPointer.new(@segment, pointer_offset(1))
      (0...pointer.length).map do |ix|
        pointer.get(ix, :u64)
      end
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      capnpVersion: capnpVersion.to_h,
      requestedFiles: requestedFiles,
    }

    class RequestedFile < CapnProto::StructPointer
      sig { returns(Integer) }
      def id = read_integer(0, :u64)

      sig { returns(String) }
      def filename = CapnProto::StringPointer.new(@segment, pointer_offset(0)).value

      # sig { returns(T::Array[Import]) }
      # def imports
      #   pointer = CapnProto::ListPointer.new(@segment, pointer_offset(1))
      #   (0...pointer.length).map do |ix|
      #     Import.new(@segment, )
      #   end
      # end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h = {
        id: id,
        filename: filename,
        imports: nil,
      }

      class Import < CapnProto::StructPointer
        sig { returns(Integer) }
        def id = read_integer(0, :u64)

        sig { returns(String) }
        def name = CapnProto::StringPointer.new(@segment, pointer_offset(0)).value

        sig { returns(T::Hash[Symbol, T.untyped]) }
        def to_h = {
          id: id,
          name: name,
        }
      end
    end
  end
end
