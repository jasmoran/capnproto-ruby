# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

module Schema
  class Node < CapnProto::Struct
    sig { returns(Integer) }
    def id = read_integer(0, false, 64, 0)

    sig { returns(T.nilable(CapnProto::String)) }
    def displayName = CapnProto::String.from_pointer(read_pointer(0))

    sig { returns(Integer) }
    def displayNamePrefixLength = read_integer(8, false, 32, 0)

    sig { returns(Integer) }
    def scopeId = read_integer(16, false, 64, 0)

    sig { returns(T.nilable(CapnProto::StructList[Parameter])) }
    def parameters = Parameter::List.from_pointer(read_pointer(5))

    sig { returns(T::Boolean) }
    def isGeneric = (read_integer(36, false, 8, 0) & 0b1) == 1

    sig { returns(T.nilable(CapnProto::StructList[NestedNode])) }
    def nestedNodes = NestedNode::List.from_pointer(read_pointer(1))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      id: id,
      displayName: displayName&.value,
      displayNamePrefixLength: displayNamePrefixLength,
      scopeId: scopeId,
      parameters: parameters&.map(&:to_h),
      isGeneric: isGeneric,
      nestedNodes: nestedNodes&.map(&:to_h),
    }

    class Parameter < CapnProto::Struct
      sig { returns(T.nilable(CapnProto::String)) }
      def name = CapnProto::String.from_pointer(read_pointer(0))

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h = {
        name: name&.value,
      }

      class List < CapnProto::StructList
        Elem = type_member {{fixed: Parameter}}

        sig { override.returns(T.class_of(Parameter)) }
        def element_class = Parameter
      end
    end

    class NestedNode < CapnProto::Struct
      sig { returns(T.nilable(CapnProto::String)) }
      def name = CapnProto::String.from_pointer(read_pointer(0))

      sig { returns(Integer) }
      def id = read_integer(0, false, 64, 0)

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h = {
        name: name&.value,
        id: id,
      }

      class List < CapnProto::StructList
        Elem = type_member {{fixed: NestedNode}}

        sig { override.returns(T.class_of(NestedNode)) }
        def element_class = NestedNode
      end
    end

    class SourceInfo < CapnProto::Struct
      sig { returns(Integer) }
      def id = read_integer(0, false, 64, 0)

      sig { returns(T.nilable(CapnProto::String)) }
      def docComment = CapnProto::String.from_pointer(read_pointer(0))

      sig { returns(T.nilable(CapnProto::StructList[Member])) }
      def members = Member::List.from_pointer(read_pointer(1))

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h = {
        id: id,
        docComment: docComment&.value,
        members: members&.map(&:to_h),
      }

      class Member < CapnProto::Struct
        sig { returns(T.nilable(CapnProto::String)) }
        def docComment = CapnProto::String.from_pointer(read_pointer(0))

        sig { returns(T::Hash[Symbol, T.untyped]) }
        def to_h = {
          docComment: docComment&.value,
        }

        class List < CapnProto::StructList
          Elem = type_member {{fixed: Member}}

          sig { override.returns(T.class_of(Member)) }
          def element_class = Member
        end
      end

      class List < CapnProto::StructList
        Elem = type_member {{fixed: SourceInfo}}

        sig { override.returns(T.class_of(SourceInfo)) }
        def element_class = SourceInfo
      end
    end

    class List < CapnProto::StructList
      Elem = type_member {{fixed: Node}}

      sig { override.returns(T.class_of(Node)) }
      def element_class = Node
    end
  end

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

    sig { returns(T.nilable(CapnProto::StructList[Node])) }
    def nodes = Node::List.from_pointer(read_pointer(0))

    sig { returns(T.nilable(CapnProto::StructList[Node::SourceInfo])) }
    def sourceInfo = Node::SourceInfo::List.from_pointer(read_pointer(3))

    sig { returns(T.nilable(CapnProto::StructList[RequestedFile])) }
    def requestedFiles = RequestedFile::List.from_pointer(read_pointer(1))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      capnpVersion: capnpVersion.to_h,
      nodes: nodes&.map(&:to_h),
      sourceInfo: sourceInfo&.map(&:to_h),
      requestedFiles: requestedFiles&.map(&:to_h),
    }

    class RequestedFile < CapnProto::Struct
      sig { returns(Integer) }
      def id = read_integer(0, false, 64, 0)

      sig { returns(T.nilable(CapnProto::String)) }
      def filename = CapnProto::String.from_pointer(read_pointer(0))

      sig { returns(T.nilable(CapnProto::StructList[Import])) }
      def imports = Import::List.from_pointer(read_pointer(1))

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h = {
        id: id,
        filename: filename&.value,
        imports: imports&.map(&:to_h),
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

        class List < CapnProto::StructList
          Elem = type_member {{fixed: Import}}

          sig { override.returns(T.class_of(Import)) }
          def element_class = Import
        end
      end

      class List < CapnProto::StructList
        Elem = type_member {{fixed: RequestedFile}}

        sig { override.returns(T.class_of(RequestedFile)) }
        def element_class = RequestedFile
      end
    end
  end
end
