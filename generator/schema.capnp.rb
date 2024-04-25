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
    sig { returns(NilClass) }
    def file = nil
    sig { returns(GroupStruct) }
    def struct = GroupStruct.new(@data, @pointers)
    class GroupStruct < CapnProto::Struct
      DEFAULT_DATAWORDCOUNT = 0
      sig { returns(Integer) }
      def dataWordCount = read_integer(14, false, 16, 0)
      DEFAULT_POINTERCOUNT = 0
      sig { returns(Integer) }
      def pointerCount = read_integer(24, false, 16, 0)
      # DEFAULT_PREFERREDLISTENCODING = Schema::ElementSize::Empty
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["dataWordCount"] = dataWordCount
        res["pointerCount"] = pointerCount
        res["preferredListEncoding"] = preferredListEncoding
        res["isGroup"] = isGroup
        res["discriminantCount"] = discriminantCount
        res["discriminantOffset"] = discriminantOffset
        res["fields"] = fields&.to_obj
        res
      end
    end
    sig { returns(GroupEnum) }
    def enum = GroupEnum.new(@data, @pointers)
    class GroupEnum < CapnProto::Struct
      sig { returns(T.nilable(CapnProto::List[Schema::Enumerant])) }
      def enumerants = Schema::Enumerant::List.from_pointer(read_pointer(3))
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["enumerants"] = enumerants&.to_obj
        res
      end
    end
    sig { returns(GroupInterface) }
    def interface = GroupInterface.new(@data, @pointers)
    class GroupInterface < CapnProto::Struct
      sig { returns(T.nilable(CapnProto::List[Schema::Method])) }
      def methods = Schema::Method::List.from_pointer(read_pointer(3))
      sig { returns(T.nilable(CapnProto::List[Schema::Superclass])) }
      def superclasses = Schema::Superclass::List.from_pointer(read_pointer(4))
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["methods"] = methods&.to_obj
        res["superclasses"] = superclasses&.to_obj
        res
      end
    end
    sig { returns(GroupConst) }
    def const = GroupConst.new(@data, @pointers)
    class GroupConst < CapnProto::Struct
      sig { returns(T.nilable(Schema::Type)) }
      def type = Schema::Type.from_pointer(read_pointer(3))
      sig { returns(T.nilable(Schema::Value)) }
      def value = Schema::Value.from_pointer(read_pointer(4))
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["type"] = type&.to_obj
        res["value"] = value&.to_obj
        res
      end
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["type"] = type&.to_obj
        res["targetsFile"] = targetsFile
        res["targetsConst"] = targetsConst
        res["targetsEnum"] = targetsEnum
        res["targetsEnumerant"] = targetsEnumerant
        res["targetsStruct"] = targetsStruct
        res["targetsField"] = targetsField
        res["targetsUnion"] = targetsUnion
        res["targetsGroup"] = targetsGroup
        res["targetsInterface"] = targetsInterface
        res["targetsMethod"] = targetsMethod
        res["targetsParam"] = targetsParam
        res["targetsAnnotation"] = targetsAnnotation
        res
      end
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["name"] = name&.to_obj
        res
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["name"] = name&.to_obj
        res["id"] = id
        res
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
        sig { override.returns(Object) }
        def to_obj
          res = {}
          res["docComment"] = docComment&.to_obj
          res
        end
      end
      class List < CapnProto::StructList
        Elem = type_member {{fixed: SourceInfo}}
        sig { override.returns(T.class_of(SourceInfo)) }
        def element_class = SourceInfo
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["id"] = id
        res["docComment"] = docComment&.to_obj
        res["members"] = members&.to_obj
        res
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["id"] = id
      res["displayName"] = displayName&.to_obj
      res["displayNamePrefixLength"] = displayNamePrefixLength
      res["scopeId"] = scopeId
      res["parameters"] = parameters&.to_obj
      res["isGeneric"] = isGeneric
      res["nestedNodes"] = nestedNodes&.to_obj
      res["annotations"] = annotations&.to_obj
      case which?
      when Which::File then res["file"] = file
      when Which::Struct then res["struct"] = struct.to_obj
      when Which::Enum then res["enum"] = enum.to_obj
      when Which::Interface then res["interface"] = interface.to_obj
      when Which::Const then res["const"] = const.to_obj
      when Which::Annotation then res["annotation"] = annotation.to_obj
      end
      res
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["offset"] = offset
        res["type"] = type&.to_obj
        res["defaultValue"] = defaultValue&.to_obj
        res["hadExplicitDefault"] = hadExplicitDefault
        res
      end
    end
    sig { returns(GroupGroup) }
    def group = GroupGroup.new(@data, @pointers)
    class GroupGroup < CapnProto::Struct
      DEFAULT_TYPEID = 0
      sig { returns(Integer) }
      def typeId = read_integer(16, false, 64, 0)
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["typeId"] = typeId
        res
      end
    end
    sig { returns(GroupOrdinal) }
    def ordinal = GroupOrdinal.new(@data, @pointers)
    class GroupOrdinal < CapnProto::Struct
      sig { returns(NilClass) }
      def implicit = nil
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        case which?
        when Which::Implicit then res["implicit"] = implicit
        when Which::Explicit then res["explicit"] = explicit
        end
        res
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["name"] = name&.to_obj
      res["codeOrder"] = codeOrder
      res["annotations"] = annotations&.to_obj
      res["discriminantValue"] = discriminantValue
      res["ordinal"] = ordinal.to_obj
      case which?
      when Which::Slot then res["slot"] = slot.to_obj
      when Which::Group then res["group"] = group.to_obj
      end
      res
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["name"] = name&.to_obj
      res["codeOrder"] = codeOrder
      res["annotations"] = annotations&.to_obj
      res
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["id"] = id
      res["brand"] = brand&.to_obj
      res
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["name"] = name&.to_obj
      res["codeOrder"] = codeOrder
      res["implicitParameters"] = implicitParameters&.to_obj
      res["paramStructType"] = paramStructType
      res["paramBrand"] = paramBrand&.to_obj
      res["resultStructType"] = resultStructType
      res["resultBrand"] = resultBrand&.to_obj
      res["annotations"] = annotations&.to_obj
      res
    end
  end
  class Type < CapnProto::Struct
    sig { returns(NilClass) }
    def void = nil
    sig { returns(NilClass) }
    def bool = nil
    sig { returns(NilClass) }
    def int8 = nil
    sig { returns(NilClass) }
    def int16 = nil
    sig { returns(NilClass) }
    def int32 = nil
    sig { returns(NilClass) }
    def int64 = nil
    sig { returns(NilClass) }
    def uint8 = nil
    sig { returns(NilClass) }
    def uint16 = nil
    sig { returns(NilClass) }
    def uint32 = nil
    sig { returns(NilClass) }
    def uint64 = nil
    sig { returns(NilClass) }
    def float32 = nil
    sig { returns(NilClass) }
    def float64 = nil
    sig { returns(NilClass) }
    def text = nil
    sig { returns(NilClass) }
    def data = nil
    sig { returns(GroupList) }
    def list = GroupList.new(@data, @pointers)
    class GroupList < CapnProto::Struct
      sig { returns(T.nilable(Schema::Type)) }
      def elementType = Schema::Type.from_pointer(read_pointer(0))
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["elementType"] = elementType&.to_obj
        res
      end
    end
    sig { returns(GroupEnum) }
    def enum = GroupEnum.new(@data, @pointers)
    class GroupEnum < CapnProto::Struct
      DEFAULT_TYPEID = 0
      sig { returns(Integer) }
      def typeId = read_integer(8, false, 64, 0)
      sig { returns(T.nilable(Schema::Brand)) }
      def brand = Schema::Brand.from_pointer(read_pointer(0))
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["typeId"] = typeId
        res["brand"] = brand&.to_obj
        res
      end
    end
    sig { returns(GroupStruct) }
    def struct = GroupStruct.new(@data, @pointers)
    class GroupStruct < CapnProto::Struct
      DEFAULT_TYPEID = 0
      sig { returns(Integer) }
      def typeId = read_integer(8, false, 64, 0)
      sig { returns(T.nilable(Schema::Brand)) }
      def brand = Schema::Brand.from_pointer(read_pointer(0))
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["typeId"] = typeId
        res["brand"] = brand&.to_obj
        res
      end
    end
    sig { returns(GroupInterface) }
    def interface = GroupInterface.new(@data, @pointers)
    class GroupInterface < CapnProto::Struct
      DEFAULT_TYPEID = 0
      sig { returns(Integer) }
      def typeId = read_integer(8, false, 64, 0)
      sig { returns(T.nilable(Schema::Brand)) }
      def brand = Schema::Brand.from_pointer(read_pointer(0))
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["typeId"] = typeId
        res["brand"] = brand&.to_obj
        res
      end
    end
    sig { returns(GroupAnyPointer) }
    def anyPointer = GroupAnyPointer.new(@data, @pointers)
    class GroupAnyPointer < CapnProto::Struct
      sig { returns(GroupUnconstrained) }
      def unconstrained = GroupUnconstrained.new(@data, @pointers)
      class GroupUnconstrained < CapnProto::Struct
        sig { returns(NilClass) }
        def anyKind = nil
        sig { returns(NilClass) }
        def struct = nil
        sig { returns(NilClass) }
        def list = nil
        sig { returns(NilClass) }
        def capability = nil
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
        sig { override.returns(Object) }
        def to_obj
          res = {}
          case which?
          when Which::AnyKind then res["anyKind"] = anyKind
          when Which::Struct then res["struct"] = struct
          when Which::List then res["list"] = list
          when Which::Capability then res["capability"] = capability
          end
          res
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
        sig { override.returns(Object) }
        def to_obj
          res = {}
          res["scopeId"] = scopeId
          res["parameterIndex"] = parameterIndex
          res
        end
      end
      sig { returns(GroupImplicitMethodParameter) }
      def implicitMethodParameter = GroupImplicitMethodParameter.new(@data, @pointers)
      class GroupImplicitMethodParameter < CapnProto::Struct
        DEFAULT_PARAMETERINDEX = 0
        sig { returns(Integer) }
        def parameterIndex = read_integer(10, false, 16, 0)
        sig { override.returns(Object) }
        def to_obj
          res = {}
          res["parameterIndex"] = parameterIndex
          res
        end
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        case which?
        when Which::Unconstrained then res["unconstrained"] = unconstrained.to_obj
        when Which::Parameter then res["parameter"] = parameter.to_obj
        when Which::ImplicitMethodParameter then res["implicitMethodParameter"] = implicitMethodParameter.to_obj
        end
        res
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      case which?
      when Which::Void then res["void"] = void
      when Which::Bool then res["bool"] = bool
      when Which::Int8 then res["int8"] = int8
      when Which::Int16 then res["int16"] = int16
      when Which::Int32 then res["int32"] = int32
      when Which::Int64 then res["int64"] = int64
      when Which::Uint8 then res["uint8"] = uint8
      when Which::Uint16 then res["uint16"] = uint16
      when Which::Uint32 then res["uint32"] = uint32
      when Which::Uint64 then res["uint64"] = uint64
      when Which::Float32 then res["float32"] = float32
      when Which::Float64 then res["float64"] = float64
      when Which::Text then res["text"] = text
      when Which::Data then res["data"] = data
      when Which::List then res["list"] = list.to_obj
      when Which::Enum then res["enum"] = enum.to_obj
      when Which::Struct then res["struct"] = struct.to_obj
      when Which::Interface then res["interface"] = interface.to_obj
      when Which::AnyPointer then res["anyPointer"] = anyPointer.to_obj
      end
      res
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
      sig { returns(NilClass) }
      def inherit = nil
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["scopeId"] = scopeId
        case which?
        when Which::Bind then res["bind"] = bind&.to_obj
        when Which::Inherit then res["inherit"] = inherit
        end
        res
      end
    end
    class Binding < CapnProto::Struct
      sig { returns(NilClass) }
      def unbound = nil
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
      sig { override.returns(Object) }
      def to_obj
        res = {}
        case which?
        when Which::Unbound then res["unbound"] = unbound
        when Which::Type then res["type"] = type&.to_obj
        end
        res
      end
    end
    class List < CapnProto::StructList
      Elem = type_member {{fixed: Brand}}
      sig { override.returns(T.class_of(Brand)) }
      def element_class = Brand
    end
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["scopes"] = scopes&.to_obj
      res
    end
  end
  class Value < CapnProto::Struct
    sig { returns(NilClass) }
    def void = nil
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
    sig { returns(NilClass) }
    def interface = nil
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      case which?
      when Which::Void then res["void"] = void
      when Which::Bool then res["bool"] = bool
      when Which::Int8 then res["int8"] = int8
      when Which::Int16 then res["int16"] = int16
      when Which::Int32 then res["int32"] = int32
      when Which::Int64 then res["int64"] = int64
      when Which::Uint8 then res["uint8"] = uint8
      when Which::Uint16 then res["uint16"] = uint16
      when Which::Uint32 then res["uint32"] = uint32
      when Which::Uint64 then res["uint64"] = uint64
      when Which::Float32 then res["float32"] = float32
      when Which::Float64 then res["float64"] = float64
      when Which::Text then res["text"] = text&.to_obj
      when Which::Data then res["data"] = data&.to_obj
      when Which::List then res["list"] = list
      when Which::Enum then res["enum"] = enum
      when Which::Struct then res["struct"] = struct
      when Which::Interface then res["interface"] = interface
      when Which::AnyPointer then res["anyPointer"] = anyPointer
      end
      res
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["id"] = id
      res["brand"] = brand&.to_obj
      res["value"] = value&.to_obj
      res
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
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["major"] = major
      res["minor"] = minor
      res["micro"] = micro
      res
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
        sig { override.returns(Object) }
        def to_obj
          res = {}
          res["id"] = id
          res["name"] = name&.to_obj
          res
        end
      end
      class List < CapnProto::StructList
        Elem = type_member {{fixed: RequestedFile}}
        sig { override.returns(T.class_of(RequestedFile)) }
        def element_class = RequestedFile
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["id"] = id
        res["filename"] = filename&.to_obj
        res["imports"] = imports&.to_obj
        res
      end
    end
    class List < CapnProto::StructList
      Elem = type_member {{fixed: CodeGeneratorRequest}}
      sig { override.returns(T.class_of(CodeGeneratorRequest)) }
      def element_class = CodeGeneratorRequest
    end
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["capnpVersion"] = capnpVersion&.to_obj
      res["nodes"] = nodes&.to_obj
      res["sourceInfo"] = sourceInfo&.to_obj
      res["requestedFiles"] = requestedFiles&.to_obj
      res
    end
  end
end