# typed: strict
require 'sorbet-runtime'
require_relative '../capnproto'
module Schema
  class Node < CapnProto::Struct
    DEFAULT_ID = 0
    sig { returns(Integer) }
    def id = read_integer(0, false, 64, 0)
    DEFAULT_DISPLAYNAME = nil
    sig { returns(T.nilable(CapnProto::String)) }
    def displayName = CapnProto::BufferString.from_pointer(read_pointer(0))
    DEFAULT_DISPLAYNAMEPREFIXLENGTH = 0
    sig { returns(Integer) }
    def displayNamePrefixLength = read_integer(8, false, 32, 0)
    DEFAULT_SCOPEID = 0
    sig { returns(Integer) }
    def scopeId = read_integer(16, false, 64, 0)
    sig { returns(T.nilable(CapnProto::List[Schema::Node::Parameter])) }
    def parameters = Schema::Node::Parameter::List.from_pointer(read_pointer(5))
    DEFAULT_ISGENERIC = false
    sig { returns(T::Boolean) }
    def isGeneric = (read_integer(36, false, 8, 0x00) & 0x1) != 0
    sig { returns(T.nilable(CapnProto::List[Schema::Node::NestedNode])) }
    def nestedNodes = Schema::Node::NestedNode::List.from_pointer(read_pointer(1))
    sig { returns(T.nilable(CapnProto::List[Schema::Annotation])) }
    def annotations = Schema::Annotation::List.from_pointer(read_pointer(2))
    sig { void }
    def file; end
    sig { returns(GroupStruct) }
    def struct = GroupStruct.new(@data, @pointers)
    class GroupStruct < CapnProto::Struct
      DEFAULT_DATAWORDCOUNT = 0
      sig { returns(Integer) }
      def dataWordCount = read_integer(14, false, 16, 0)
      DEFAULT_POINTERCOUNT = 0
      sig { returns(Integer) }
      def pointerCount = read_integer(24, false, 16, 0)
      DEFAULT_PREFERREDLISTENCODING = Schema::ElementSize::Empty
      sig { returns(Schema::ElementSize) }
      def preferredListEncoding = Schema::ElementSize.from_integer(read_integer(26, false, 16, 0))
      DEFAULT_ISGROUP = false
      sig { returns(T::Boolean) }
      def isGroup = (read_integer(28, false, 8, 0x00) & 0x1) != 0
      DEFAULT_DISCRIMINANTCOUNT = 0
      sig { returns(Integer) }
      def discriminantCount = read_integer(30, false, 16, 0)
      DEFAULT_DISCRIMINANTOFFSET = 0
      sig { returns(Integer) }
      def discriminantOffset = read_integer(32, false, 32, 0)
      sig { returns(T.nilable(CapnProto::List[Schema::Field])) }
      def fields = Schema::Field::List.from_pointer(read_pointer(3))
    end
    sig { returns(GroupEnum) }
    def enum = GroupEnum.new(@data, @pointers)
    class GroupEnum < CapnProto::Struct
      sig { returns(T.nilable(CapnProto::List[Schema::Enumerant])) }
      def enumerants = Schema::Enumerant::List.from_pointer(read_pointer(3))
    end
    sig { returns(GroupInterface) }
    def interface = GroupInterface.new(@data, @pointers)
    class GroupInterface < CapnProto::Struct
      sig { returns(T.nilable(CapnProto::List[Schema::Method])) }
      def methods = Schema::Method::List.from_pointer(read_pointer(3))
      sig { returns(T.nilable(CapnProto::List[Schema::Superclass])) }
      def superclasses = Schema::Superclass::List.from_pointer(read_pointer(4))
    end
    sig { returns(GroupConst) }
    def const = GroupConst.new(@data, @pointers)
    class GroupConst < CapnProto::Struct
      sig { returns(T.nilable(Schema::Type)) }
      def type = Schema::Type.from_pointer(read_pointer(3))
      sig { returns(T.nilable(Schema::Value)) }
      def value = Schema::Value.from_pointer(read_pointer(4))
    end
    sig { returns(GroupAnnotation) }
    def annotation = GroupAnnotation.new(@data, @pointers)
    class GroupAnnotation < CapnProto::Struct
      sig { returns(T.nilable(Schema::Type)) }
      def type = Schema::Type.from_pointer(read_pointer(3))
      DEFAULT_TARGETSFILE = false
      sig { returns(T::Boolean) }
      def targetsFile = (read_integer(14, false, 8, 0x00) & 0x1) != 0
      DEFAULT_TARGETSCONST = false
      sig { returns(T::Boolean) }
      def targetsConst = (read_integer(14, false, 8, 0x00) & 0x2) != 0
      DEFAULT_TARGETSENUM = false
      sig { returns(T::Boolean) }
      def targetsEnum = (read_integer(14, false, 8, 0x00) & 0x4) != 0
      DEFAULT_TARGETSENUMERANT = false
      sig { returns(T::Boolean) }
      def targetsEnumerant = (read_integer(14, false, 8, 0x00) & 0x8) != 0
      DEFAULT_TARGETSSTRUCT = false
      sig { returns(T::Boolean) }
      def targetsStruct = (read_integer(14, false, 8, 0x00) & 0x10) != 0
      DEFAULT_TARGETSFIELD = false
      sig { returns(T::Boolean) }
      def targetsField = (read_integer(14, false, 8, 0x00) & 0x20) != 0
      DEFAULT_TARGETSUNION = false
      sig { returns(T::Boolean) }
      def targetsUnion = (read_integer(14, false, 8, 0x00) & 0x40) != 0
      DEFAULT_TARGETSGROUP = false
      sig { returns(T::Boolean) }
      def targetsGroup = (read_integer(14, false, 8, 0x00) & 0x80) != 0
      DEFAULT_TARGETSINTERFACE = false
      sig { returns(T::Boolean) }
      def targetsInterface = (read_integer(15, false, 8, 0x00) & 0x1) != 0
      DEFAULT_TARGETSMETHOD = false
      sig { returns(T::Boolean) }
      def targetsMethod = (read_integer(15, false, 8, 0x00) & 0x2) != 0
      DEFAULT_TARGETSPARAM = false
      sig { returns(T::Boolean) }
      def targetsParam = (read_integer(15, false, 8, 0x00) & 0x4) != 0
      DEFAULT_TARGETSANNOTATION = false
      sig { returns(T::Boolean) }
      def targetsAnnotation = (read_integer(15, false, 8, 0x00) & 0x8) != 0
    end
    class Parameter < CapnProto::Struct
      DEFAULT_NAME = nil
      sig { returns(T.nilable(CapnProto::String)) }
      def name = CapnProto::BufferString.from_pointer(read_pointer(0))
      class List < CapnProto::StructList
        Elem = type_member {{fixed: Parameter}}
        sig { override.returns(T.class_of(Parameter)) }
        def element_class = Parameter
      end
    end
    class NestedNode < CapnProto::Struct
      DEFAULT_NAME = nil
      sig { returns(T.nilable(CapnProto::String)) }
      def name = CapnProto::BufferString.from_pointer(read_pointer(0))
      DEFAULT_ID = 0
      sig { returns(Integer) }
      def id = read_integer(0, false, 64, 0)
      class List < CapnProto::StructList
        Elem = type_member {{fixed: NestedNode}}
        sig { override.returns(T.class_of(NestedNode)) }
        def element_class = NestedNode
      end
    end
    class SourceInfo < CapnProto::Struct
      DEFAULT_ID = 0
      sig { returns(Integer) }
      def id = read_integer(0, false, 64, 0)
      DEFAULT_DOCCOMMENT = nil
      sig { returns(T.nilable(CapnProto::String)) }
      def docComment = CapnProto::BufferString.from_pointer(read_pointer(0))
      sig { returns(T.nilable(CapnProto::List[Schema::Node::SourceInfo::Member])) }
      def members = Schema::Node::SourceInfo::Member::List.from_pointer(read_pointer(1))
      class Member < CapnProto::Struct
        DEFAULT_DOCCOMMENT = nil
        sig { returns(T.nilable(CapnProto::String)) }
        def docComment = CapnProto::BufferString.from_pointer(read_pointer(0))
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
    sig { returns(Which) }
    def which? = Which.from_integer(read_integer(12, false, 16, 0))
    class Which < T::Enum
      extend T::Sig
      enums do
        File = new("file")
        Struct = new("struct")
        Enum = new("enum")
        Interface = new("interface")
        Const = new("const")
        Annotation = new("annotation")
      end
      sig { params(value: Integer).returns(Which) }
      def self.from_integer(value)
        case value
        when 0 then File
        when 1 then Struct
        when 2 then Enum
        when 3 then Interface
        when 4 then Const
        when 5 then Annotation
        else raise "Unknown Which value: #{value}"
        end
      end
    end
  end
  class Field < CapnProto::Struct
    DEFAULT_NAME = nil
    sig { returns(T.nilable(CapnProto::String)) }
    def name = CapnProto::BufferString.from_pointer(read_pointer(0))
    DEFAULT_CODEORDER = 0
    sig { returns(Integer) }
    def codeOrder = read_integer(0, false, 16, 0)
    sig { returns(T.nilable(CapnProto::List[Schema::Annotation])) }
    def annotations = Schema::Annotation::List.from_pointer(read_pointer(1))
    DEFAULT_DISCRIMINANTVALUE = 65535
    sig { returns(Integer) }
    def discriminantValue = read_integer(2, false, 16, 65535)
    sig { returns(GroupSlot) }
    def slot = GroupSlot.new(@data, @pointers)
    class GroupSlot < CapnProto::Struct
      DEFAULT_OFFSET = 0
      sig { returns(Integer) }
      def offset = read_integer(4, false, 32, 0)
      sig { returns(T.nilable(Schema::Type)) }
      def type = Schema::Type.from_pointer(read_pointer(2))
      sig { returns(T.nilable(Schema::Value)) }
      def defaultValue = Schema::Value.from_pointer(read_pointer(3))
      DEFAULT_HADEXPLICITDEFAULT = false
      sig { returns(T::Boolean) }
      def hadExplicitDefault = (read_integer(16, false, 8, 0x00) & 0x1) != 0
    end
    sig { returns(GroupGroup) }
    def group = GroupGroup.new(@data, @pointers)
    class GroupGroup < CapnProto::Struct
      DEFAULT_TYPEID = 0
      sig { returns(Integer) }
      def typeId = read_integer(16, false, 64, 0)
    end
    sig { returns(GroupOrdinal) }
    def ordinal = GroupOrdinal.new(@data, @pointers)
    class GroupOrdinal < CapnProto::Struct
      sig { void }
      def implicit; end
      DEFAULT_EXPLICIT = 0
      sig { returns(Integer) }
      def explicit = read_integer(12, false, 16, 0)
      sig { returns(Which) }
      def which? = Which.from_integer(read_integer(10, false, 16, 0))
      class Which < T::Enum
        extend T::Sig
        enums do
          Implicit = new("implicit")
          Explicit = new("explicit")
        end
        sig { params(value: Integer).returns(Which) }
        def self.from_integer(value)
          case value
          when 0 then Implicit
          when 1 then Explicit
          else raise "Unknown Which value: #{value}"
          end
        end
      end
    end
    NoDiscriminant = 65535
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Field}}
      sig { override.returns(T.class_of(Field)) }
      def element_class = Field
    end
    sig { returns(Which) }
    def which? = Which.from_integer(read_integer(8, false, 16, 0))
    class Which < T::Enum
      extend T::Sig
      enums do
        Slot = new("slot")
        Group = new("group")
      end
      sig { params(value: Integer).returns(Which) }
      def self.from_integer(value)
        case value
        when 0 then Slot
        when 1 then Group
        else raise "Unknown Which value: #{value}"
        end
      end
    end
  end
  class Enumerant < CapnProto::Struct
    DEFAULT_NAME = nil
    sig { returns(T.nilable(CapnProto::String)) }
    def name = CapnProto::BufferString.from_pointer(read_pointer(0))
    DEFAULT_CODEORDER = 0
    sig { returns(Integer) }
    def codeOrder = read_integer(0, false, 16, 0)
    sig { returns(T.nilable(CapnProto::List[Schema::Annotation])) }
    def annotations = Schema::Annotation::List.from_pointer(read_pointer(1))
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Enumerant}}
      sig { override.returns(T.class_of(Enumerant)) }
      def element_class = Enumerant
    end
  end
  class Superclass < CapnProto::Struct
    DEFAULT_ID = 0
    sig { returns(Integer) }
    def id = read_integer(0, false, 64, 0)
    sig { returns(T.nilable(Schema::Brand)) }
    def brand = Schema::Brand.from_pointer(read_pointer(0))
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Superclass}}
      sig { override.returns(T.class_of(Superclass)) }
      def element_class = Superclass
    end
  end
  class Method < CapnProto::Struct
    DEFAULT_NAME = nil
    sig { returns(T.nilable(CapnProto::String)) }
    def name = CapnProto::BufferString.from_pointer(read_pointer(0))
    DEFAULT_CODEORDER = 0
    sig { returns(Integer) }
    def codeOrder = read_integer(0, false, 16, 0)
    sig { returns(T.nilable(CapnProto::List[Schema::Node::Parameter])) }
    def implicitParameters = Schema::Node::Parameter::List.from_pointer(read_pointer(4))
    DEFAULT_PARAMSTRUCTTYPE = 0
    sig { returns(Integer) }
    def paramStructType = read_integer(8, false, 64, 0)
    sig { returns(T.nilable(Schema::Brand)) }
    def paramBrand = Schema::Brand.from_pointer(read_pointer(2))
    DEFAULT_RESULTSTRUCTTYPE = 0
    sig { returns(Integer) }
    def resultStructType = read_integer(16, false, 64, 0)
    sig { returns(T.nilable(Schema::Brand)) }
    def resultBrand = Schema::Brand.from_pointer(read_pointer(3))
    sig { returns(T.nilable(CapnProto::List[Schema::Annotation])) }
    def annotations = Schema::Annotation::List.from_pointer(read_pointer(1))
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Method}}
      sig { override.returns(T.class_of(Method)) }
      def element_class = Method
    end
  end
  class Type < CapnProto::Struct
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
      sig { returns(T.nilable(Schema::Type)) }
      def elementType = Schema::Type.from_pointer(read_pointer(0))
    end
    sig { returns(GroupEnum) }
    def enum = GroupEnum.new(@data, @pointers)
    class GroupEnum < CapnProto::Struct
      DEFAULT_TYPEID = 0
      sig { returns(Integer) }
      def typeId = read_integer(8, false, 64, 0)
      sig { returns(T.nilable(Schema::Brand)) }
      def brand = Schema::Brand.from_pointer(read_pointer(0))
    end
    sig { returns(GroupStruct) }
    def struct = GroupStruct.new(@data, @pointers)
    class GroupStruct < CapnProto::Struct
      DEFAULT_TYPEID = 0
      sig { returns(Integer) }
      def typeId = read_integer(8, false, 64, 0)
      sig { returns(T.nilable(Schema::Brand)) }
      def brand = Schema::Brand.from_pointer(read_pointer(0))
    end
    sig { returns(GroupInterface) }
    def interface = GroupInterface.new(@data, @pointers)
    class GroupInterface < CapnProto::Struct
      DEFAULT_TYPEID = 0
      sig { returns(Integer) }
      def typeId = read_integer(8, false, 64, 0)
      sig { returns(T.nilable(Schema::Brand)) }
      def brand = Schema::Brand.from_pointer(read_pointer(0))
    end
    sig { returns(GroupAnyPointer) }
    def anyPointer = GroupAnyPointer.new(@data, @pointers)
    class GroupAnyPointer < CapnProto::Struct
      sig { returns(GroupUnconstrained) }
      def unconstrained = GroupUnconstrained.new(@data, @pointers)
      class GroupUnconstrained < CapnProto::Struct
        sig { void }
        def anyKind; end
        sig { void }
        def struct; end
        sig { void }
        def list; end
        sig { void }
        def capability; end
        sig { returns(Which) }
        def which? = Which.from_integer(read_integer(10, false, 16, 0))
        class Which < T::Enum
          extend T::Sig
          enums do
            AnyKind = new("anyKind")
            Struct = new("struct")
            List = new("list")
            Capability = new("capability")
          end
          sig { params(value: Integer).returns(Which) }
          def self.from_integer(value)
            case value
            when 0 then AnyKind
            when 1 then Struct
            when 2 then List
            when 3 then Capability
            else raise "Unknown Which value: #{value}"
            end
          end
        end
      end
      sig { returns(GroupParameter) }
      def parameter = GroupParameter.new(@data, @pointers)
      class GroupParameter < CapnProto::Struct
        DEFAULT_SCOPEID = 0
        sig { returns(Integer) }
        def scopeId = read_integer(16, false, 64, 0)
        DEFAULT_PARAMETERINDEX = 0
        sig { returns(Integer) }
        def parameterIndex = read_integer(10, false, 16, 0)
      end
      sig { returns(GroupImplicitMethodParameter) }
      def implicitMethodParameter = GroupImplicitMethodParameter.new(@data, @pointers)
      class GroupImplicitMethodParameter < CapnProto::Struct
        DEFAULT_PARAMETERINDEX = 0
        sig { returns(Integer) }
        def parameterIndex = read_integer(10, false, 16, 0)
      end
      sig { returns(Which) }
      def which? = Which.from_integer(read_integer(8, false, 16, 0))
      class Which < T::Enum
        extend T::Sig
        enums do
          Unconstrained = new("unconstrained")
          Parameter = new("parameter")
          ImplicitMethodParameter = new("implicitMethodParameter")
        end
        sig { params(value: Integer).returns(Which) }
        def self.from_integer(value)
          case value
          when 0 then Unconstrained
          when 1 then Parameter
          when 2 then ImplicitMethodParameter
          else raise "Unknown Which value: #{value}"
          end
        end
      end
    end
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Type}}
      sig { override.returns(T.class_of(Type)) }
      def element_class = Type
    end
    sig { returns(Which) }
    def which? = Which.from_integer(read_integer(0, false, 16, 0))
    class Which < T::Enum
      extend T::Sig
      enums do
        Void = new("void")
        Bool = new("bool")
        Int8 = new("int8")
        Int16 = new("int16")
        Int32 = new("int32")
        Int64 = new("int64")
        Uint8 = new("uint8")
        Uint16 = new("uint16")
        Uint32 = new("uint32")
        Uint64 = new("uint64")
        Float32 = new("float32")
        Float64 = new("float64")
        Text = new("text")
        Data = new("data")
        List = new("list")
        Enum = new("enum")
        Struct = new("struct")
        Interface = new("interface")
        AnyPointer = new("anyPointer")
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
        else raise "Unknown Which value: #{value}"
        end
      end
    end
  end
  class Brand < CapnProto::Struct
    sig { returns(T.nilable(CapnProto::List[Schema::Brand::Scope])) }
    def scopes = Schema::Brand::Scope::List.from_pointer(read_pointer(0))
    class Scope < CapnProto::Struct
      DEFAULT_SCOPEID = 0
      sig { returns(Integer) }
      def scopeId = read_integer(0, false, 64, 0)
      sig { returns(T.nilable(CapnProto::List[Schema::Brand::Binding])) }
      def bind = Schema::Brand::Binding::List.from_pointer(read_pointer(0))
      sig { void }
      def inherit; end
      class List < CapnProto::StructList
        Elem = type_member {{fixed: Scope}}
        sig { override.returns(T.class_of(Scope)) }
        def element_class = Scope
      end
      sig { returns(Which) }
      def which? = Which.from_integer(read_integer(8, false, 16, 0))
      class Which < T::Enum
        extend T::Sig
        enums do
          Bind = new("bind")
          Inherit = new("inherit")
        end
        sig { params(value: Integer).returns(Which) }
        def self.from_integer(value)
          case value
          when 0 then Bind
          when 1 then Inherit
          else raise "Unknown Which value: #{value}"
          end
        end
      end
    end
    class Binding < CapnProto::Struct
      sig { void }
      def unbound; end
      sig { returns(T.nilable(Schema::Type)) }
      def type = Schema::Type.from_pointer(read_pointer(0))
      class List < CapnProto::StructList
        Elem = type_member {{fixed: Binding}}
        sig { override.returns(T.class_of(Binding)) }
        def element_class = Binding
      end
      sig { returns(Which) }
      def which? = Which.from_integer(read_integer(0, false, 16, 0))
      class Which < T::Enum
        extend T::Sig
        enums do
          Unbound = new("unbound")
          Type = new("type")
        end
        sig { params(value: Integer).returns(Which) }
        def self.from_integer(value)
          case value
          when 0 then Unbound
          when 1 then Type
          else raise "Unknown Which value: #{value}"
          end
        end
      end
    end
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Brand}}
      sig { override.returns(T.class_of(Brand)) }
      def element_class = Brand
    end
  end
  class Value < CapnProto::Struct
    sig { void }
    def void; end
    DEFAULT_BOOL = false
    sig { returns(T::Boolean) }
    def bool = (read_integer(2, false, 8, 0x00) & 0x1) != 0
    DEFAULT_INT8 = 0
    sig { returns(Integer) }
    def int8 = read_integer(2, true, 8, 0)
    DEFAULT_INT16 = 0
    sig { returns(Integer) }
    def int16 = read_integer(2, true, 16, 0)
    DEFAULT_INT32 = 0
    sig { returns(Integer) }
    def int32 = read_integer(4, true, 32, 0)
    DEFAULT_INT64 = 0
    sig { returns(Integer) }
    def int64 = read_integer(8, true, 64, 0)
    DEFAULT_UINT8 = 0
    sig { returns(Integer) }
    def uint8 = read_integer(2, false, 8, 0)
    DEFAULT_UINT16 = 0
    sig { returns(Integer) }
    def uint16 = read_integer(2, false, 16, 0)
    DEFAULT_UINT32 = 0
    sig { returns(Integer) }
    def uint32 = read_integer(4, false, 32, 0)
    DEFAULT_UINT64 = 0
    sig { returns(Integer) }
    def uint64 = read_integer(8, false, 64, 0)
    DEFAULT_FLOAT32 = 0.0
    sig { returns(Float) }
    def float32 = read_float(4, 32, 0.0)
    DEFAULT_FLOAT64 = 0.0
    sig { returns(Float) }
    def float64 = read_float(8, 64, 0.0)
    DEFAULT_TEXT = nil
    sig { returns(T.nilable(CapnProto::String)) }
    def text = CapnProto::BufferString.from_pointer(read_pointer(0))
    DEFAULT_DATA = nil
    sig { returns(T.nilable(CapnProto::Data)) }
    def data = CapnProto::Data.from_pointer(read_pointer(0))
    sig { returns(CapnProto::Reference) }
    def list = read_pointer(0)
    DEFAULT_ENUM = 0
    sig { returns(Integer) }
    def enum = read_integer(2, false, 16, 0)
    sig { returns(CapnProto::Reference) }
    def struct = read_pointer(0)
    sig { void }
    def interface; end
    sig { returns(CapnProto::Reference) }
    def anyPointer = read_pointer(0)
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Value}}
      sig { override.returns(T.class_of(Value)) }
      def element_class = Value
    end
    sig { returns(Which) }
    def which? = Which.from_integer(read_integer(0, false, 16, 0))
    class Which < T::Enum
      extend T::Sig
      enums do
        Void = new("void")
        Bool = new("bool")
        Int8 = new("int8")
        Int16 = new("int16")
        Int32 = new("int32")
        Int64 = new("int64")
        Uint8 = new("uint8")
        Uint16 = new("uint16")
        Uint32 = new("uint32")
        Uint64 = new("uint64")
        Float32 = new("float32")
        Float64 = new("float64")
        Text = new("text")
        Data = new("data")
        List = new("list")
        Enum = new("enum")
        Struct = new("struct")
        Interface = new("interface")
        AnyPointer = new("anyPointer")
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
        else raise "Unknown Which value: #{value}"
        end
      end
    end
  end
  class Annotation < CapnProto::Struct
    DEFAULT_ID = 0
    sig { returns(Integer) }
    def id = read_integer(0, false, 64, 0)
    sig { returns(T.nilable(Schema::Brand)) }
    def brand = Schema::Brand.from_pointer(read_pointer(1))
    sig { returns(T.nilable(Schema::Value)) }
    def value = Schema::Value.from_pointer(read_pointer(0))
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Annotation}}
      sig { override.returns(T.class_of(Annotation)) }
      def element_class = Annotation
    end
  end
  class ElementSize < T::Enum
    extend T::Sig
    enums do
      Empty = new("empty")
      Bit = new("bit")
      Byte = new("byte")
      TwoBytes = new("twoBytes")
      FourBytes = new("fourBytes")
      EightBytes = new("eightBytes")
      Pointer = new("pointer")
      InlineComposite = new("inlineComposite")
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
    DEFAULT_MAJOR = 0
    sig { returns(Integer) }
    def major = read_integer(0, false, 16, 0)
    DEFAULT_MINOR = 0
    sig { returns(Integer) }
    def minor = read_integer(2, false, 8, 0)
    DEFAULT_MICRO = 0
    sig { returns(Integer) }
    def micro = read_integer(3, false, 8, 0)
    class List < CapnProto::StructList
      Elem = type_member {{fixed: CapnpVersion}}
      sig { override.returns(T.class_of(CapnpVersion)) }
      def element_class = CapnpVersion
    end
  end
  class CodeGeneratorRequest < CapnProto::Struct
    sig { returns(T.nilable(Schema::CapnpVersion)) }
    def capnpVersion = Schema::CapnpVersion.from_pointer(read_pointer(2))
    sig { returns(T.nilable(CapnProto::List[Schema::Node])) }
    def nodes = Schema::Node::List.from_pointer(read_pointer(0))
    sig { returns(T.nilable(CapnProto::List[Schema::Node::SourceInfo])) }
    def sourceInfo = Schema::Node::SourceInfo::List.from_pointer(read_pointer(3))
    sig { returns(T.nilable(CapnProto::List[Schema::CodeGeneratorRequest::RequestedFile])) }
    def requestedFiles = Schema::CodeGeneratorRequest::RequestedFile::List.from_pointer(read_pointer(1))
    class RequestedFile < CapnProto::Struct
      DEFAULT_ID = 0
      sig { returns(Integer) }
      def id = read_integer(0, false, 64, 0)
      DEFAULT_FILENAME = nil
      sig { returns(T.nilable(CapnProto::String)) }
      def filename = CapnProto::BufferString.from_pointer(read_pointer(0))
      sig { returns(T.nilable(CapnProto::List[Schema::CodeGeneratorRequest::RequestedFile::Import])) }
      def imports = Schema::CodeGeneratorRequest::RequestedFile::Import::List.from_pointer(read_pointer(1))
      class Import < CapnProto::Struct
        DEFAULT_ID = 0
        sig { returns(Integer) }
        def id = read_integer(0, false, 64, 0)
        DEFAULT_NAME = nil
        sig { returns(T.nilable(CapnProto::String)) }
        def name = CapnProto::BufferString.from_pointer(read_pointer(0))
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
    class List < CapnProto::StructList
      Elem = type_member {{fixed: CodeGeneratorRequest}}
      sig { override.returns(T.class_of(CodeGeneratorRequest)) }
      def element_class = CodeGeneratorRequest
    end
  end
end