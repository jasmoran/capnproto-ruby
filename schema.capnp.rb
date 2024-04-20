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

    sig { returns(T.nilable(CapnProto::StructList[Annotation])) }
    def annotations = Annotation::List.from_pointer(read_pointer(2))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      id: id,
      displayName: displayName&.value,
      displayNamePrefixLength: displayNamePrefixLength,
      scopeId: scopeId,
      parameters: parameters&.map(&:to_h),
      isGeneric: isGeneric,
      nestedNodes: nestedNodes&.map(&:to_h),
      annotations: annotations&.map(&:to_h),
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

  class Enumerant < CapnProto::Struct
    sig { returns(T.nilable(CapnProto::String)) }
    def name = CapnProto::String.from_pointer(read_pointer(0))

    sig { returns(Integer) }
    def codeOrder = read_integer(0, false, 16, 0)

    sig { returns(T.nilable(CapnProto::StructList[Annotation])) }
    def annotations = Annotation::List.from_pointer(read_pointer(1))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      name: name&.value,
      codeOrder: codeOrder,
      annotations: annotations&.map(&:to_h),
    }

    class List < CapnProto::StructList
      Elem = type_member {{fixed: Enumerant}}

      sig { override.returns(T.class_of(Enumerant)) }
      def element_class = Enumerant
    end
  end

  class Superclass < CapnProto::Struct
    sig { returns(Integer) }
    def id = read_integer(0, false, 64, 0)

    sig { returns(T.nilable(Brand)) }
    def brand = Brand.from_pointer(read_pointer(0))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      id: id,
      brand: brand&.to_h,
    }

    class List < CapnProto::StructList
      Elem = type_member {{fixed: Superclass}}

      sig { override.returns(T.class_of(Superclass)) }
      def element_class = Superclass
    end
  end

  class Method < CapnProto::Struct
    sig { returns(T.nilable(CapnProto::String)) }
    def name = CapnProto::String.from_pointer(read_pointer(0))

    sig { returns(Integer) }
    def codeOrder = read_integer(0, false, 16, 0)

    sig { returns(T.nilable(CapnProto::StructList[Node::Parameter])) }
    def implicitParameters = Node::Parameter::List.from_pointer(read_pointer(4))

    sig { returns(Integer) }
    def paramStructType = read_integer(8, false, 64, 0)

    sig { returns(T.nilable(Brand)) }
    def paramBrand = Brand.from_pointer(read_pointer(2))

    sig { returns(Integer) }
    def resultStructType = read_integer(16, false, 64, 0)

    sig { returns(T.nilable(Brand)) }
    def resultBrand = Brand.from_pointer(read_pointer(3))

    sig { returns(T.nilable(CapnProto::StructList[Annotation])) }
    def annotations = Annotation::List.from_pointer(read_pointer(1))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      name: name&.value,
      codeOrder: codeOrder,
      implicitParameters: implicitParameters&.map(&:to_h),
      paramStructType: paramStructType,
      paramBrand: paramBrand&.to_h,
      resultStructType: resultStructType,
      resultBrand: resultBrand&.to_h,
      annotations: annotations&.map(&:to_h),
    }

    class List < CapnProto::StructList
      Elem = type_member {{fixed: Method}}

      sig { override.returns(T.class_of(Method)) }
      def element_class = Method
    end
  end

  class Type < CapnProto::Struct
    sig { returns(Which) }
    def which = Which.from_integer(read_integer(0, false, 16, 0))

    sig { void }
    def void; end

    sig { void }
    def bool; end

    sig { void }
    def int8; end

    sig { void }
    def int16; end

    sig { void }
    def int32; end

    sig { void }
    def int64; end

    sig { void }
    def uint8; end

    sig { void }
    def uint16; end

    sig { void }
    def uint32; end

    sig { void }
    def uint64; end

    sig { void }
    def float32; end

    sig { void }
    def float64; end

    sig { void }
    def text; end

    sig { void }
    def data; end

    sig { returns(GroupList) }
    def list = GroupList.new(@data, @pointers)

    class GroupList < CapnProto::Struct
      sig { returns(T.nilable(Type)) }
      def elementType = Type.from_pointer(read_pointer(0))

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h = {
        elementType: elementType&.to_h,
      }
    end

    sig { returns(GroupEnum) }
    def enum = GroupEnum.new(@data, @pointers)

    sig { returns(GroupEnum) }
    def struct = GroupEnum.new(@data, @pointers)

    sig { returns(GroupEnum) }
    def interface = GroupEnum.new(@data, @pointers)

    class GroupEnum < CapnProto::Struct
      sig { returns(Integer) }
      def typeId = read_integer(8, false, 64, 0)

      sig { returns(T.nilable(Brand)) }
      def brand = Brand.from_pointer(read_pointer(0))

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h = {
        typeId: typeId,
        brand: brand&.to_h,
      }
    end

    sig { returns(GroupAnyPointer) }
    def anyPointer = GroupAnyPointer.new(@data, @pointers)

    class GroupAnyPointer < CapnProto::Struct
      sig { returns(Which) }
      def which = Which.from_integer(read_integer(8, false, 16, 0))

      sig { returns(GroupUnconstrained) }
      def unconstrained = GroupUnconstrained.new(@data, @pointers)

      class GroupUnconstrained < CapnProto::Struct
        sig { returns(Which) }
        def which = Which.from_integer(read_integer(10, false, 16, 0))

        sig { void }
        def anyKind; end

        sig { void }
        def struct; end

        sig { void }
        def list; end

        sig { void }
        def capability; end

        sig { returns(T::Hash[Symbol, T.untyped]) }
        def to_h
          which_val = which
          case which_val
          when Which::AnyKind then {anyKind: nil}
          when Which::Struct then {struct: nil}
          when Which::List then {list: nil}
          when Which::Capability then {capability: nil}
          else T.absurd(which_val)
          end
        end

        class Which < T::Enum
          extend T::Sig

          enums do
            AnyKind = new
            Struct = new
            List = new
            Capability = new
          end

          sig { params(value: Integer).returns(Which) }
          def self.from_integer(value)
            case value
            when 0 then AnyKind
            when 1 then Struct
            when 2 then List
            when 2 then Capability
            else raise "Unknown Unconstrained value: #{value}"
            end
          end
        end
      end

      sig { returns(GroupParameter) }
      def parameter = GroupParameter.new(@data, @pointers)

      class GroupParameter < CapnProto::Struct
        sig { returns(Integer) }
        def scopeId = read_integer(16, false, 64, 0)

        sig { returns(Integer) }
        def parameterIndex = read_integer(10, false, 16, 0)

        sig { returns(T::Hash[Symbol, T.untyped]) }
        def to_h = {
          scopeId: scopeId,
          parameterIndex: parameterIndex,
        }
      end

      sig { returns(GroupImplicitMethodParameter) }
      def implicitMethodParameter = GroupImplicitMethodParameter.new(@data, @pointers)

      class GroupImplicitMethodParameter < CapnProto::Struct
        sig { returns(Integer) }
        def parameterIndex = read_integer(10, false, 16, 0)

        sig { returns(T::Hash[Symbol, T.untyped]) }
        def to_h = {parameterIndex: parameterIndex}
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h
        which_val = which
        case which_val
        when Which::Unconstrained then {unconstrained: unconstrained.to_h}
        when Which::Parameter then {parameter: parameter.to_h}
        when Which::ImplicitMethodParameter then {implicitMethodParameter: implicitMethodParameter.to_h}
        else T.absurd(which_val)
        end
      end

      class Which < T::Enum
        extend T::Sig

        enums do
          Unconstrained = new
          Parameter = new
          ImplicitMethodParameter = new
        end

        sig { params(value: Integer).returns(Which) }
        def self.from_integer(value)
          case value
          when 0 then Unconstrained
          when 1 then Parameter
          when 2 then ImplicitMethodParameter
          else raise "Unknown AnyPointer value: #{value}"
          end
        end
      end
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h
      which_val = which
      case which_val
      when Which::Void then {void: nil}
      when Which::Bool then {bool: nil}
      when Which::Int8 then {int8: nil}
      when Which::Int16 then {int16: nil}
      when Which::Int32 then {int32: nil}
      when Which::Int64 then {int64: nil}
      when Which::Uint8 then {uint8: nil}
      when Which::Uint16 then {uint16: nil}
      when Which::Uint32 then {uint32: nil}
      when Which::Uint64 then {uint64: nil}
      when Which::Float32 then {float32: nil}
      when Which::Float64 then {float64: nil}
      when Which::Text then {text: nil}
      when Which::Data then {data: nil}
      when Which::List then {list: list.to_h}
      when Which::Enum then {enum: enum.to_h}
      when Which::Struct then {struct: struct.to_h}
      when Which::Interface then {interface: interface.to_h}
      when Which::AnyPointer then {anyPointer: anyPointer.to_h}
      else T.absurd(which_val)
      end
    end

    class Which < T::Enum
      extend T::Sig

      enums do
        Void = new
        Bool = new
        Int8 = new
        Int16 = new
        Int32 = new
        Int64 = new
        Uint8 = new
        Uint16 = new
        Uint32 = new
        Uint64 = new
        Float32 = new
        Float64 = new
        Text = new
        Data = new
        List = new
        Enum = new
        Struct = new
        Interface = new
        AnyPointer = new
      end

      sig { params(value: Integer).returns(Which) }
      def self.from_integer(value)
        case value
        when 0 then Void
        when 1 then Bool
        when 2 then Int8
        when 3 then Int16
        when 4 then Int32
        when 5 then Int64
        when 6 then Uint8
        when 7 then Uint16
        when 8 then Uint32
        when 9 then Uint64
        when 10 then Float32
        when 11 then Float64
        when 12 then Text
        when 13 then Data
        when 14 then List
        when 15 then Enum
        when 16 then Struct
        when 17 then Interface
        when 18 then AnyPointer
        else raise "Unknown Type value: #{value}"
        end
      end
    end
  end

  class Brand < CapnProto::Struct
    sig { returns(T.nilable(CapnProto::StructList[Scope])) }
    def scopes = Scope::List.from_pointer(read_pointer(0))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      scopes: scopes&.map(&:to_h),
    }

    class Scope < CapnProto::Struct
      sig { returns(Integer) }
      def scopeId = read_integer(0, false, 64, 0)

      sig { returns(Which) }
      def which = Which.from_integer(read_integer(8, false, 16, 0))

      sig { returns(T.nilable(CapnProto::StructList[Binding])) }
      def bind = Binding::List.from_pointer(read_pointer(0))

      sig { void }
      def inherit; end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h
        res = { scopeId: scopeId }
        which_val = which
        case which_val
        when Which::Bind then res[:bind] = bind&.map(&:to_h)
        when Which::Inherit then res[:inherit] = nil
        else T.absurd(which_val)
        end
        res
      end

      class Which < T::Enum
        extend T::Sig

        enums do
          Bind = new
          Inherit = new
        end

        sig { params(value: Integer).returns(Which) }
        def self.from_integer(value)
          case value
          when 0 then Bind
          when 1 then Inherit
          else raise "Unknown Scope value: #{value}"
          end
        end
      end

      class List < CapnProto::StructList
        Elem = type_member {{fixed: Scope}}

        sig { override.returns(T.class_of(Scope)) }
        def element_class = Scope
      end
    end

    class Binding < CapnProto::Struct
      sig { returns(Which) }
      def which = Which.from_integer(read_integer(0, false, 16, 0))

      sig { void }
      def unbound; end

      sig { returns(T.nilable(Type)) }
      def type = Type.from_pointer(read_pointer(0))

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h
        which_val = which
        case which_val
        when Which::Unbound then {unbound: nil}
        when Which::Type then {type: type&.to_h}
        else T.absurd(which_val)
        end
      end

      class Which < T::Enum
        extend T::Sig

        enums do
          Unbound = new
          Type = new
        end

        sig { params(value: Integer).returns(Which) }
        def self.from_integer(value)
          case value
          when 0 then Unbound
          when 1 then Type
          else raise "Unknown Binding value: #{value}"
          end
        end
      end

      class List < CapnProto::StructList
        Elem = type_member {{fixed: Binding}}

        sig { override.returns(T.class_of(Binding)) }
        def element_class = Binding
      end
    end
  end

  class Value < CapnProto::Struct
    sig { returns(Which) }
    def which = Which.from_integer(read_integer(0, false, 16, 0))

    sig { void }
    def void; end

    sig { returns(T::Boolean) }
    def bool = (read_integer(2, false, 8, 0) & 0b1) == 1

    sig { returns(Integer) }
    def int8 = read_integer(2, true, 8, 0)

    sig { returns(Integer) }
    def int16 = read_integer(2, true, 16, 0)

    sig { returns(Integer) }
    def int32 = read_integer(4, true, 32, 0)

    sig { returns(Integer) }
    def int64 = read_integer(8, true, 64, 0)

    sig { returns(Integer) }
    def uint8 = read_integer(2, false, 8, 0)

    sig { returns(Integer) }
    def uint16 = read_integer(2, false, 16, 0)

    sig { returns(Integer) }
    def uint32 = read_integer(4, false, 32, 0)

    sig { returns(Integer) }
    def uint64 = read_integer(8, false, 64, 0)

    sig { returns(Integer) }
    def float32 = read_integer(4, false, 32, 0) #TODO

    sig { returns(Integer) }
    def float64 = read_integer(8, false, 64, 0) #TODO

    sig { returns(T.nilable(CapnProto::String)) }
    def text = CapnProto::String.from_pointer(read_pointer(0))

    sig { returns(T.nilable(CapnProto::Data)) }
    def data = CapnProto::Data.from_pointer(read_pointer(0))

    sig { returns(Integer) }
    def list = read_pointer(0).read_integer(0, false, 64) #TODO

    sig { returns(Integer) }
    def enum = read_integer(2, false, 16, 0)

    sig { returns(Integer) }
    def struct = read_pointer(0).read_integer(0, false, 64) #TODO

    sig { void }
    def interface; end

    sig { returns(Integer) }
    def anyPointer = read_pointer(0).read_integer(0, false, 64) #TODO

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h
      which_val = which
      case which_val
      when Which::Void then {void: nil}
      when Which::Bool then {bool: bool}
      when Which::Int8 then {int8: int8}
      when Which::Int16 then {int16: int16}
      when Which::Int32 then {int32: int32}
      when Which::Int64 then {int64: int64}
      when Which::Uint8 then {uint8: uint8}
      when Which::Uint16 then {uint16: uint16}
      when Which::Uint32 then {uint32: uint32}
      when Which::Uint64 then {uint64: uint64}
      when Which::Float32 then {float32: float32}
      when Which::Float64 then {float64: float64}
      when Which::Text then {text: text&.value}
      when Which::Data then {data: data&.value}
      when Which::List then {list: list}
      when Which::Enum then {enum: enum}
      when Which::Struct then {struct: struct}
      when Which::Interface then {interface: nil}
      when Which::AnyPointer then {anyPointer: anyPointer}
      else T.absurd(which_val)
      end
    end

    class Which < T::Enum
      extend T::Sig

      enums do
        Void = new
        Bool = new
        Int8 = new
        Int16 = new
        Int32 = new
        Int64 = new
        Uint8 = new
        Uint16 = new
        Uint32 = new
        Uint64 = new
        Float32 = new
        Float64 = new
        Text = new
        Data = new
        List = new
        Enum = new
        Struct = new
        Interface = new
        AnyPointer = new
      end

      sig { params(value: Integer).returns(Which) }
      def self.from_integer(value)
        case value
        when 0 then Void
        when 1 then Bool
        when 2 then Int8
        when 3 then Int16
        when 4 then Int32
        when 5 then Int64
        when 6 then Uint8
        when 7 then Uint16
        when 8 then Uint32
        when 9 then Uint64
        when 10 then Float32
        when 11 then Float64
        when 12 then Text
        when 13 then Data
        when 14 then List
        when 15 then Enum
        when 16 then Struct
        when 17 then Interface
        when 18 then AnyPointer
        else raise "Unknown Value value: #{value}"
        end
      end
    end
  end

  class Annotation < CapnProto::Struct
    sig { returns(Integer) }
    def id = read_integer(0, false, 64, 0)

    sig { returns(T.nilable(Brand)) }
    def brand = Brand.from_pointer(read_pointer(1))

    sig { returns(T.nilable(Value)) }
    def value = Value.from_pointer(read_pointer(0))

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      id: id,
      brand: brand&.to_h,
      value: value&.to_h,
    }

    class List < CapnProto::StructList
      Elem = type_member {{fixed: Annotation}}

      sig { override.returns(T.class_of(Annotation)) }
      def element_class = Annotation
    end
  end

  class ElementSize < T::Enum
    extend T::Sig

    enums do
      Empty = new
      Bit = new
      Byte = new
      TwoBytes = new
      FourBytes = new
      EightBytes = new
      Pointer = new
      InlineComposite = new
    end

    sig { params(value: Integer).returns(ElementSize) }
    def self.from_integer(value)
      case value
      when 0 then Empty
      when 1 then Bit
      when 2 then Byte
      when 3 then TwoBytes
      when 4 then FourBytes
      when 5 then EightBytes
      when 6 then Pointer
      when 7 then InlineComposite
      else raise "Unknown ElementSize value: #{value}"
      end
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
