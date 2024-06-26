# typed: strict

require "capnp"
require "sorbet-runtime"
module Schema
  class Node < Capnp::Struct
    DEFAULT_ID = 0
    sig { returns(Integer) }
    def id
      read_u64(0, 0)
    end
    DEFAULT_DISPLAY_NAME = nil
    sig { returns(T.nilable(Capnp::String)) }
    def display_name
      Capnp::BufferString.from_pointer(read_pointer(0))
    end
    DEFAULT_DISPLAY_NAME_PREFIX_LENGTH = 0
    sig { returns(Integer) }
    def display_name_prefix_length
      read_u32(8, 0)
    end
    DEFAULT_SCOPE_ID = 0
    sig { returns(Integer) }
    def scope_id
      read_u64(16, 0)
    end
    sig { returns(T.nilable(Capnp::List[Schema::Node::Parameter])) }
    def parameters
      Schema::Node::Parameter::List.from_pointer(read_pointer(5))
    end
    DEFAULT_IS_GENERIC = false
    sig { returns(T::Boolean) }
    def is_generic
      (read_u8(36, 0x00) & 0x1) != 0
    end
    sig { returns(T.nilable(Capnp::List[Schema::Node::NestedNode])) }
    def nested_nodes
      Schema::Node::NestedNode::List.from_pointer(read_pointer(1))
    end
    sig { returns(T.nilable(Capnp::List[Schema::Annotation])) }
    def annotations
      Schema::Annotation::List.from_pointer(read_pointer(2))
    end
    sig { returns(NilClass) }
    def file
      nil
    end
    sig { returns(T::Boolean) }
    def is_file?
      which? == Which::File
    end
    sig { returns(GroupStruct) }
    def struct
      GroupStruct.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupStruct < Capnp::Struct
      DEFAULT_DATA_WORD_COUNT = 0
      sig { returns(Integer) }
      def data_word_count
        read_u16(14, 0)
      end
      DEFAULT_POINTER_COUNT = 0
      sig { returns(Integer) }
      def pointer_count
        read_u16(24, 0)
      end
      # DEFAULT_PREFERRED_LIST_ENCODING = Schema::ElementSize::Empty
      sig { returns(Schema::ElementSize) }
      def preferred_list_encoding
        Schema::ElementSize.from_integer(read_u16(26, 0))
      end
      DEFAULT_IS_GROUP = false
      sig { returns(T::Boolean) }
      def is_group
        (read_u8(28, 0x00) & 0x1) != 0
      end
      DEFAULT_DISCRIMINANT_COUNT = 0
      sig { returns(Integer) }
      def discriminant_count
        read_u16(30, 0)
      end
      DEFAULT_DISCRIMINANT_OFFSET = 0
      sig { returns(Integer) }
      def discriminant_offset
        read_u32(32, 0)
      end
      sig { returns(T.nilable(Capnp::List[Schema::Field])) }
      def fields
        Schema::Field::List.from_pointer(read_pointer(3))
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["data_word_count"] = data_word_count
        res["pointer_count"] = pointer_count
        res["preferred_list_encoding"] = preferred_list_encoding
        res["is_group"] = is_group
        res["discriminant_count"] = discriminant_count
        res["discriminant_offset"] = discriminant_offset
        res["fields"] = fields&.to_obj
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_struct?
      which? == Which::Struct
    end
    sig { returns(GroupEnum) }
    def enum
      GroupEnum.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupEnum < Capnp::Struct
      sig { returns(T.nilable(Capnp::List[Schema::Enumerant])) }
      def enumerants
        Schema::Enumerant::List.from_pointer(read_pointer(3))
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["enumerants"] = enumerants&.to_obj
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_enum?
      which? == Which::Enum
    end
    sig { returns(GroupInterface) }
    def interface
      GroupInterface.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupInterface < Capnp::Struct
      sig { returns(T.nilable(Capnp::List[Schema::Method])) }
      def methods
        Schema::Method::List.from_pointer(read_pointer(3))
      end
      sig { returns(T.nilable(Capnp::List[Schema::Superclass])) }
      def superclasses
        Schema::Superclass::List.from_pointer(read_pointer(4))
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["methods"] = methods&.to_obj
        res["superclasses"] = superclasses&.to_obj
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_interface?
      which? == Which::Interface
    end
    sig { returns(GroupConst) }
    def const
      GroupConst.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupConst < Capnp::Struct
      sig { returns(T.nilable(Schema::Type)) }
      def type
        Schema::Type.from_pointer(read_pointer(3))
      end
      sig { returns(T.nilable(Schema::Value)) }
      def value
        Schema::Value.from_pointer(read_pointer(4))
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["type"] = type&.to_obj
        res["value"] = value&.to_obj
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_const?
      which? == Which::Const
    end
    sig { returns(GroupAnnotation) }
    def annotation
      GroupAnnotation.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupAnnotation < Capnp::Struct
      sig { returns(T.nilable(Schema::Type)) }
      def type
        Schema::Type.from_pointer(read_pointer(3))
      end
      DEFAULT_TARGETS_FILE = false
      sig { returns(T::Boolean) }
      def targets_file
        (read_u8(14, 0x00) & 0x1) != 0
      end
      DEFAULT_TARGETS_CONST = false
      sig { returns(T::Boolean) }
      def targets_const
        (read_u8(14, 0x00) & 0x2) != 0
      end
      DEFAULT_TARGETS_ENUM = false
      sig { returns(T::Boolean) }
      def targets_enum
        (read_u8(14, 0x00) & 0x4) != 0
      end
      DEFAULT_TARGETS_ENUMERANT = false
      sig { returns(T::Boolean) }
      def targets_enumerant
        (read_u8(14, 0x00) & 0x8) != 0
      end
      DEFAULT_TARGETS_STRUCT = false
      sig { returns(T::Boolean) }
      def targets_struct
        (read_u8(14, 0x00) & 0x10) != 0
      end
      DEFAULT_TARGETS_FIELD = false
      sig { returns(T::Boolean) }
      def targets_field
        (read_u8(14, 0x00) & 0x20) != 0
      end
      DEFAULT_TARGETS_UNION = false
      sig { returns(T::Boolean) }
      def targets_union
        (read_u8(14, 0x00) & 0x40) != 0
      end
      DEFAULT_TARGETS_GROUP = false
      sig { returns(T::Boolean) }
      def targets_group
        (read_u8(14, 0x00) & 0x80) != 0
      end
      DEFAULT_TARGETS_INTERFACE = false
      sig { returns(T::Boolean) }
      def targets_interface
        (read_u8(15, 0x00) & 0x1) != 0
      end
      DEFAULT_TARGETS_METHOD = false
      sig { returns(T::Boolean) }
      def targets_method
        (read_u8(15, 0x00) & 0x2) != 0
      end
      DEFAULT_TARGETS_PARAM = false
      sig { returns(T::Boolean) }
      def targets_param
        (read_u8(15, 0x00) & 0x4) != 0
      end
      DEFAULT_TARGETS_ANNOTATION = false
      sig { returns(T::Boolean) }
      def targets_annotation
        (read_u8(15, 0x00) & 0x8) != 0
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["type"] = type&.to_obj
        res["targets_file"] = targets_file
        res["targets_const"] = targets_const
        res["targets_enum"] = targets_enum
        res["targets_enumerant"] = targets_enumerant
        res["targets_struct"] = targets_struct
        res["targets_field"] = targets_field
        res["targets_union"] = targets_union
        res["targets_group"] = targets_group
        res["targets_interface"] = targets_interface
        res["targets_method"] = targets_method
        res["targets_param"] = targets_param
        res["targets_annotation"] = targets_annotation
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_annotation?
      which? == Which::Annotation
    end

    class Parameter < Capnp::Struct
      DEFAULT_NAME = nil
      sig { returns(T.nilable(Capnp::String)) }
      def name
        Capnp::BufferString.from_pointer(read_pointer(0))
      end

      class List < Capnp::StructList
        Elem = type_member { {fixed: Parameter} }
        sig { override.returns(T.class_of(Parameter)) }
        def element_class
          Parameter
        end
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["name"] = name&.to_obj
        res
      end
    end

    class NestedNode < Capnp::Struct
      DEFAULT_NAME = nil
      sig { returns(T.nilable(Capnp::String)) }
      def name
        Capnp::BufferString.from_pointer(read_pointer(0))
      end
      DEFAULT_ID = 0
      sig { returns(Integer) }
      def id
        read_u64(0, 0)
      end

      class List < Capnp::StructList
        Elem = type_member { {fixed: NestedNode} }
        sig { override.returns(T.class_of(NestedNode)) }
        def element_class
          NestedNode
        end
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["name"] = name&.to_obj
        res["id"] = id
        res
      end
    end

    class SourceInfo < Capnp::Struct
      DEFAULT_ID = 0
      sig { returns(Integer) }
      def id
        read_u64(0, 0)
      end
      DEFAULT_DOC_COMMENT = nil
      sig { returns(T.nilable(Capnp::String)) }
      def doc_comment
        Capnp::BufferString.from_pointer(read_pointer(0))
      end
      sig { returns(T.nilable(Capnp::List[Schema::Node::SourceInfo::Member])) }
      def members
        Schema::Node::SourceInfo::Member::List.from_pointer(read_pointer(1))
      end

      class Member < Capnp::Struct
        DEFAULT_DOC_COMMENT = nil
        sig { returns(T.nilable(Capnp::String)) }
        def doc_comment
          Capnp::BufferString.from_pointer(read_pointer(0))
        end

        class List < Capnp::StructList
          Elem = type_member { {fixed: Member} }
          sig { override.returns(T.class_of(Member)) }
          def element_class
            Member
          end
        end
        sig { override.returns(Object) }
        def to_obj
          res = {}
          res["doc_comment"] = doc_comment&.to_obj
          res
        end
      end

      class List < Capnp::StructList
        Elem = type_member { {fixed: SourceInfo} }
        sig { override.returns(T.class_of(SourceInfo)) }
        def element_class
          SourceInfo
        end
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["id"] = id
        res["doc_comment"] = doc_comment&.to_obj
        res["members"] = members&.to_obj
        res
      end
    end

    class List < Capnp::StructList
      Elem = type_member { {fixed: Node} }
      sig { override.returns(T.class_of(Node)) }
      def element_class
        Node
      end
    end
    sig { returns(Which) }
    def which?
      Which.from_integer(read_u16(12, 0))
    end

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
      res["display_name"] = display_name&.to_obj
      res["display_name_prefix_length"] = display_name_prefix_length
      res["scope_id"] = scope_id
      res["parameters"] = parameters&.to_obj
      res["is_generic"] = is_generic
      res["nested_nodes"] = nested_nodes&.to_obj
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

  class Field < Capnp::Struct
    DEFAULT_NAME = nil
    sig { returns(T.nilable(Capnp::String)) }
    def name
      Capnp::BufferString.from_pointer(read_pointer(0))
    end
    DEFAULT_CODE_ORDER = 0
    sig { returns(Integer) }
    def code_order
      read_u16(0, 0)
    end
    sig { returns(T.nilable(Capnp::List[Schema::Annotation])) }
    def annotations
      Schema::Annotation::List.from_pointer(read_pointer(1))
    end
    DEFAULT_DISCRIMINANT_VALUE = 65535
    sig { returns(Integer) }
    def discriminant_value
      read_u16(2, 65535)
    end
    sig { returns(GroupSlot) }
    def slot
      GroupSlot.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupSlot < Capnp::Struct
      DEFAULT_OFFSET = 0
      sig { returns(Integer) }
      def offset
        read_u32(4, 0)
      end
      sig { returns(T.nilable(Schema::Type)) }
      def type
        Schema::Type.from_pointer(read_pointer(2))
      end
      sig { returns(T.nilable(Schema::Value)) }
      def default_value
        Schema::Value.from_pointer(read_pointer(3))
      end
      DEFAULT_HAD_EXPLICIT_DEFAULT = false
      sig { returns(T::Boolean) }
      def had_explicit_default
        (read_u8(16, 0x00) & 0x1) != 0
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["offset"] = offset
        res["type"] = type&.to_obj
        res["default_value"] = default_value&.to_obj
        res["had_explicit_default"] = had_explicit_default
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_slot?
      which? == Which::Slot
    end
    sig { returns(GroupGroup) }
    def group
      GroupGroup.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupGroup < Capnp::Struct
      DEFAULT_TYPE_ID = 0
      sig { returns(Integer) }
      def type_id
        read_u64(16, 0)
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["type_id"] = type_id
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_group?
      which? == Which::Group
    end
    sig { returns(GroupOrdinal) }
    def ordinal
      GroupOrdinal.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupOrdinal < Capnp::Struct
      sig { returns(NilClass) }
      def implicit
        nil
      end
      sig { returns(T::Boolean) }
      def is_implicit?
        which? == Which::Implicit
      end
      DEFAULT_EXPLICIT = 0
      sig { returns(Integer) }
      def explicit
        read_u16(12, 0)
      end
      sig { returns(T::Boolean) }
      def is_explicit?
        which? == Which::Explicit
      end
      sig { returns(Which) }
      def which?
        Which.from_integer(read_u16(10, 0))
      end

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
    NO_DISCRIMINANT = 65535

    class List < Capnp::StructList
      Elem = type_member { {fixed: Field} }
      sig { override.returns(T.class_of(Field)) }
      def element_class
        Field
      end
    end
    sig { returns(Which) }
    def which?
      Which.from_integer(read_u16(8, 0))
    end

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
      res["code_order"] = code_order
      res["annotations"] = annotations&.to_obj
      res["discriminant_value"] = discriminant_value
      res["ordinal"] = ordinal.to_obj
      case which?
      when Which::Slot then res["slot"] = slot.to_obj
      when Which::Group then res["group"] = group.to_obj
      end
      res
    end
  end

  class Enumerant < Capnp::Struct
    DEFAULT_NAME = nil
    sig { returns(T.nilable(Capnp::String)) }
    def name
      Capnp::BufferString.from_pointer(read_pointer(0))
    end
    DEFAULT_CODE_ORDER = 0
    sig { returns(Integer) }
    def code_order
      read_u16(0, 0)
    end
    sig { returns(T.nilable(Capnp::List[Schema::Annotation])) }
    def annotations
      Schema::Annotation::List.from_pointer(read_pointer(1))
    end

    class List < Capnp::StructList
      Elem = type_member { {fixed: Enumerant} }
      sig { override.returns(T.class_of(Enumerant)) }
      def element_class
        Enumerant
      end
    end
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["name"] = name&.to_obj
      res["code_order"] = code_order
      res["annotations"] = annotations&.to_obj
      res
    end
  end

  class Superclass < Capnp::Struct
    DEFAULT_ID = 0
    sig { returns(Integer) }
    def id
      read_u64(0, 0)
    end
    sig { returns(T.nilable(Schema::Brand)) }
    def brand
      Schema::Brand.from_pointer(read_pointer(0))
    end

    class List < Capnp::StructList
      Elem = type_member { {fixed: Superclass} }
      sig { override.returns(T.class_of(Superclass)) }
      def element_class
        Superclass
      end
    end
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["id"] = id
      res["brand"] = brand&.to_obj
      res
    end
  end

  class Method < Capnp::Struct
    DEFAULT_NAME = nil
    sig { returns(T.nilable(Capnp::String)) }
    def name
      Capnp::BufferString.from_pointer(read_pointer(0))
    end
    DEFAULT_CODE_ORDER = 0
    sig { returns(Integer) }
    def code_order
      read_u16(0, 0)
    end
    sig { returns(T.nilable(Capnp::List[Schema::Node::Parameter])) }
    def implicit_parameters
      Schema::Node::Parameter::List.from_pointer(read_pointer(4))
    end
    DEFAULT_PARAM_STRUCT_TYPE = 0
    sig { returns(Integer) }
    def param_struct_type
      read_u64(8, 0)
    end
    sig { returns(T.nilable(Schema::Brand)) }
    def param_brand
      Schema::Brand.from_pointer(read_pointer(2))
    end
    DEFAULT_RESULT_STRUCT_TYPE = 0
    sig { returns(Integer) }
    def result_struct_type
      read_u64(16, 0)
    end
    sig { returns(T.nilable(Schema::Brand)) }
    def result_brand
      Schema::Brand.from_pointer(read_pointer(3))
    end
    sig { returns(T.nilable(Capnp::List[Schema::Annotation])) }
    def annotations
      Schema::Annotation::List.from_pointer(read_pointer(1))
    end

    class List < Capnp::StructList
      Elem = type_member { {fixed: Method} }
      sig { override.returns(T.class_of(Method)) }
      def element_class
        Method
      end
    end
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["name"] = name&.to_obj
      res["code_order"] = code_order
      res["implicit_parameters"] = implicit_parameters&.to_obj
      res["param_struct_type"] = param_struct_type
      res["param_brand"] = param_brand&.to_obj
      res["result_struct_type"] = result_struct_type
      res["result_brand"] = result_brand&.to_obj
      res["annotations"] = annotations&.to_obj
      res
    end
  end

  class Type < Capnp::Struct
    sig { returns(NilClass) }
    def void
      nil
    end
    sig { returns(T::Boolean) }
    def is_void?
      which? == Which::Void
    end
    sig { returns(NilClass) }
    def bool
      nil
    end
    sig { returns(T::Boolean) }
    def is_bool?
      which? == Which::Bool
    end
    sig { returns(NilClass) }
    def int8
      nil
    end
    sig { returns(T::Boolean) }
    def is_int8?
      which? == Which::Int8
    end
    sig { returns(NilClass) }
    def int16
      nil
    end
    sig { returns(T::Boolean) }
    def is_int16?
      which? == Which::Int16
    end
    sig { returns(NilClass) }
    def int32
      nil
    end
    sig { returns(T::Boolean) }
    def is_int32?
      which? == Which::Int32
    end
    sig { returns(NilClass) }
    def int64
      nil
    end
    sig { returns(T::Boolean) }
    def is_int64?
      which? == Which::Int64
    end
    sig { returns(NilClass) }
    def uint8
      nil
    end
    sig { returns(T::Boolean) }
    def is_uint8?
      which? == Which::Uint8
    end
    sig { returns(NilClass) }
    def uint16
      nil
    end
    sig { returns(T::Boolean) }
    def is_uint16?
      which? == Which::Uint16
    end
    sig { returns(NilClass) }
    def uint32
      nil
    end
    sig { returns(T::Boolean) }
    def is_uint32?
      which? == Which::Uint32
    end
    sig { returns(NilClass) }
    def uint64
      nil
    end
    sig { returns(T::Boolean) }
    def is_uint64?
      which? == Which::Uint64
    end
    sig { returns(NilClass) }
    def float32
      nil
    end
    sig { returns(T::Boolean) }
    def is_float32?
      which? == Which::Float32
    end
    sig { returns(NilClass) }
    def float64
      nil
    end
    sig { returns(T::Boolean) }
    def is_float64?
      which? == Which::Float64
    end
    sig { returns(NilClass) }
    def text
      nil
    end
    sig { returns(T::Boolean) }
    def is_text?
      which? == Which::Text
    end
    sig { returns(NilClass) }
    def data
      nil
    end
    sig { returns(T::Boolean) }
    def is_data?
      which? == Which::Data
    end
    sig { returns(GroupList) }
    def list
      GroupList.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupList < Capnp::Struct
      sig { returns(T.nilable(Schema::Type)) }
      def element_type
        Schema::Type.from_pointer(read_pointer(0))
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["element_type"] = element_type&.to_obj
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_list?
      which? == Which::List
    end
    sig { returns(GroupEnum) }
    def enum
      GroupEnum.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupEnum < Capnp::Struct
      DEFAULT_TYPE_ID = 0
      sig { returns(Integer) }
      def type_id
        read_u64(8, 0)
      end
      sig { returns(T.nilable(Schema::Brand)) }
      def brand
        Schema::Brand.from_pointer(read_pointer(0))
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["type_id"] = type_id
        res["brand"] = brand&.to_obj
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_enum?
      which? == Which::Enum
    end
    sig { returns(GroupStruct) }
    def struct
      GroupStruct.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupStruct < Capnp::Struct
      DEFAULT_TYPE_ID = 0
      sig { returns(Integer) }
      def type_id
        read_u64(8, 0)
      end
      sig { returns(T.nilable(Schema::Brand)) }
      def brand
        Schema::Brand.from_pointer(read_pointer(0))
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["type_id"] = type_id
        res["brand"] = brand&.to_obj
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_struct?
      which? == Which::Struct
    end
    sig { returns(GroupInterface) }
    def interface
      GroupInterface.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupInterface < Capnp::Struct
      DEFAULT_TYPE_ID = 0
      sig { returns(Integer) }
      def type_id
        read_u64(8, 0)
      end
      sig { returns(T.nilable(Schema::Brand)) }
      def brand
        Schema::Brand.from_pointer(read_pointer(0))
      end
      sig { override.returns(Object) }
      def to_obj
        res = {}
        res["type_id"] = type_id
        res["brand"] = brand&.to_obj
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_interface?
      which? == Which::Interface
    end
    sig { returns(GroupAnyPointer) }
    def any_pointer
      GroupAnyPointer.new(@data, @data_size, @pointers, @pointers_size)
    end

    class GroupAnyPointer < Capnp::Struct
      sig { returns(GroupUnconstrained) }
      def unconstrained
        GroupUnconstrained.new(@data, @data_size, @pointers, @pointers_size)
      end

      class GroupUnconstrained < Capnp::Struct
        sig { returns(NilClass) }
        def any_kind
          nil
        end
        sig { returns(T::Boolean) }
        def is_any_kind?
          which? == Which::AnyKind
        end
        sig { returns(NilClass) }
        def struct
          nil
        end
        sig { returns(T::Boolean) }
        def is_struct?
          which? == Which::Struct
        end
        sig { returns(NilClass) }
        def list
          nil
        end
        sig { returns(T::Boolean) }
        def is_list?
          which? == Which::List
        end
        sig { returns(NilClass) }
        def capability
          nil
        end
        sig { returns(T::Boolean) }
        def is_capability?
          which? == Which::Capability
        end
        sig { returns(Which) }
        def which?
          Which.from_integer(read_u16(10, 0))
        end

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
          when Which::AnyKind then res["any_kind"] = any_kind
          when Which::Struct then res["struct"] = struct
          when Which::List then res["list"] = list
          when Which::Capability then res["capability"] = capability
          end
          res
        end
      end
      sig { returns(T::Boolean) }
      def is_unconstrained?
        which? == Which::Unconstrained
      end
      sig { returns(GroupParameter) }
      def parameter
        GroupParameter.new(@data, @data_size, @pointers, @pointers_size)
      end

      class GroupParameter < Capnp::Struct
        DEFAULT_SCOPE_ID = 0
        sig { returns(Integer) }
        def scope_id
          read_u64(16, 0)
        end
        DEFAULT_PARAMETER_INDEX = 0
        sig { returns(Integer) }
        def parameter_index
          read_u16(10, 0)
        end
        sig { override.returns(Object) }
        def to_obj
          res = {}
          res["scope_id"] = scope_id
          res["parameter_index"] = parameter_index
          res
        end
      end
      sig { returns(T::Boolean) }
      def is_parameter?
        which? == Which::Parameter
      end
      sig { returns(GroupImplicitMethodParameter) }
      def implicit_method_parameter
        GroupImplicitMethodParameter.new(@data, @data_size, @pointers, @pointers_size)
      end

      class GroupImplicitMethodParameter < Capnp::Struct
        DEFAULT_PARAMETER_INDEX = 0
        sig { returns(Integer) }
        def parameter_index
          read_u16(10, 0)
        end
        sig { override.returns(Object) }
        def to_obj
          res = {}
          res["parameter_index"] = parameter_index
          res
        end
      end
      sig { returns(T::Boolean) }
      def is_implicit_method_parameter?
        which? == Which::ImplicitMethodParameter
      end
      sig { returns(Which) }
      def which?
        Which.from_integer(read_u16(8, 0))
      end

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
        when Which::ImplicitMethodParameter then res["implicit_method_parameter"] = implicit_method_parameter.to_obj
        end
        res
      end
    end
    sig { returns(T::Boolean) }
    def is_any_pointer?
      which? == Which::AnyPointer
    end

    class List < Capnp::StructList
      Elem = type_member { {fixed: Type} }
      sig { override.returns(T.class_of(Type)) }
      def element_class
        Type
      end
    end
    sig { returns(Which) }
    def which?
      Which.from_integer(read_u16(0, 0))
    end

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
      when Which::AnyPointer then res["any_pointer"] = any_pointer.to_obj
      end
      res
    end
  end

  class Brand < Capnp::Struct
    sig { returns(T.nilable(Capnp::List[Schema::Brand::Scope])) }
    def scopes
      Schema::Brand::Scope::List.from_pointer(read_pointer(0))
    end

    class Scope < Capnp::Struct
      DEFAULT_SCOPE_ID = 0
      sig { returns(Integer) }
      def scope_id
        read_u64(0, 0)
      end
      sig { returns(T.nilable(Capnp::List[Schema::Brand::Binding])) }
      def bind
        Schema::Brand::Binding::List.from_pointer(read_pointer(0))
      end
      sig { returns(T::Boolean) }
      def is_bind?
        which? == Which::Bind
      end
      sig { returns(NilClass) }
      def inherit
        nil
      end
      sig { returns(T::Boolean) }
      def is_inherit?
        which? == Which::Inherit
      end

      class List < Capnp::StructList
        Elem = type_member { {fixed: Scope} }
        sig { override.returns(T.class_of(Scope)) }
        def element_class
          Scope
        end
      end
      sig { returns(Which) }
      def which?
        Which.from_integer(read_u16(8, 0))
      end

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
        res["scope_id"] = scope_id
        case which?
        when Which::Bind then res["bind"] = bind&.to_obj
        when Which::Inherit then res["inherit"] = inherit
        end
        res
      end
    end

    class Binding < Capnp::Struct
      sig { returns(NilClass) }
      def unbound
        nil
      end
      sig { returns(T::Boolean) }
      def is_unbound?
        which? == Which::Unbound
      end
      sig { returns(T.nilable(Schema::Type)) }
      def type
        Schema::Type.from_pointer(read_pointer(0))
      end
      sig { returns(T::Boolean) }
      def is_type?
        which? == Which::Type
      end

      class List < Capnp::StructList
        Elem = type_member { {fixed: Binding} }
        sig { override.returns(T.class_of(Binding)) }
        def element_class
          Binding
        end
      end
      sig { returns(Which) }
      def which?
        Which.from_integer(read_u16(0, 0))
      end

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

    class List < Capnp::StructList
      Elem = type_member { {fixed: Brand} }
      sig { override.returns(T.class_of(Brand)) }
      def element_class
        Brand
      end
    end
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["scopes"] = scopes&.to_obj
      res
    end
  end

  class Value < Capnp::Struct
    sig { returns(NilClass) }
    def void
      nil
    end
    sig { returns(T::Boolean) }
    def is_void?
      which? == Which::Void
    end
    DEFAULT_BOOL = false
    sig { returns(T::Boolean) }
    def bool
      (read_u8(2, 0x00) & 0x1) != 0
    end
    sig { returns(T::Boolean) }
    def is_bool?
      which? == Which::Bool
    end
    DEFAULT_INT8 = 0
    sig { returns(Integer) }
    def int8
      read_s8(2, 0)
    end
    sig { returns(T::Boolean) }
    def is_int8?
      which? == Which::Int8
    end
    DEFAULT_INT16 = 0
    sig { returns(Integer) }
    def int16
      read_s16(2, 0)
    end
    sig { returns(T::Boolean) }
    def is_int16?
      which? == Which::Int16
    end
    DEFAULT_INT32 = 0
    sig { returns(Integer) }
    def int32
      read_s32(4, 0)
    end
    sig { returns(T::Boolean) }
    def is_int32?
      which? == Which::Int32
    end
    DEFAULT_INT64 = 0
    sig { returns(Integer) }
    def int64
      read_s64(8, 0)
    end
    sig { returns(T::Boolean) }
    def is_int64?
      which? == Which::Int64
    end
    DEFAULT_UINT8 = 0
    sig { returns(Integer) }
    def uint8
      read_u8(2, 0)
    end
    sig { returns(T::Boolean) }
    def is_uint8?
      which? == Which::Uint8
    end
    DEFAULT_UINT16 = 0
    sig { returns(Integer) }
    def uint16
      read_u16(2, 0)
    end
    sig { returns(T::Boolean) }
    def is_uint16?
      which? == Which::Uint16
    end
    DEFAULT_UINT32 = 0
    sig { returns(Integer) }
    def uint32
      read_u32(4, 0)
    end
    sig { returns(T::Boolean) }
    def is_uint32?
      which? == Which::Uint32
    end
    DEFAULT_UINT64 = 0
    sig { returns(Integer) }
    def uint64
      read_u64(8, 0)
    end
    sig { returns(T::Boolean) }
    def is_uint64?
      which? == Which::Uint64
    end
    DEFAULT_FLOAT32 = 0.0
    sig { returns(Float) }
    def float32
      read_f32(4, 0.0)
    end
    sig { returns(T::Boolean) }
    def is_float32?
      which? == Which::Float32
    end
    DEFAULT_FLOAT64 = 0.0
    sig { returns(Float) }
    def float64
      read_f64(8, 0.0)
    end
    sig { returns(T::Boolean) }
    def is_float64?
      which? == Which::Float64
    end
    DEFAULT_TEXT = nil
    sig { returns(T.nilable(Capnp::String)) }
    def text
      Capnp::BufferString.from_pointer(read_pointer(0))
    end
    sig { returns(T::Boolean) }
    def is_text?
      which? == Which::Text
    end
    DEFAULT_DATA = nil
    sig { returns(T.nilable(Capnp::Data)) }
    def data
      Capnp::Data.from_pointer(read_pointer(0))
    end
    sig { returns(T::Boolean) }
    def is_data?
      which? == Which::Data
    end
    sig { returns(Capnp::Reference) }
    def list
      read_pointer(0)
    end
    sig { returns(T::Boolean) }
    def is_list?
      which? == Which::List
    end
    DEFAULT_ENUM = 0
    sig { returns(Integer) }
    def enum
      read_u16(2, 0)
    end
    sig { returns(T::Boolean) }
    def is_enum?
      which? == Which::Enum
    end
    sig { returns(Capnp::Reference) }
    def struct
      read_pointer(0)
    end
    sig { returns(T::Boolean) }
    def is_struct?
      which? == Which::Struct
    end
    sig { returns(NilClass) }
    def interface
      nil
    end
    sig { returns(T::Boolean) }
    def is_interface?
      which? == Which::Interface
    end
    sig { returns(Capnp::Reference) }
    def any_pointer
      read_pointer(0)
    end
    sig { returns(T::Boolean) }
    def is_any_pointer?
      which? == Which::AnyPointer
    end

    class List < Capnp::StructList
      Elem = type_member { {fixed: Value} }
      sig { override.returns(T.class_of(Value)) }
      def element_class
        Value
      end
    end
    sig { returns(Which) }
    def which?
      Which.from_integer(read_u16(0, 0))
    end

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
      when Which::AnyPointer then res["any_pointer"] = any_pointer
      end
      res
    end
  end

  class Annotation < Capnp::Struct
    DEFAULT_ID = 0
    sig { returns(Integer) }
    def id
      read_u64(0, 0)
    end
    sig { returns(T.nilable(Schema::Brand)) }
    def brand
      Schema::Brand.from_pointer(read_pointer(1))
    end
    sig { returns(T.nilable(Schema::Value)) }
    def value
      Schema::Value.from_pointer(read_pointer(0))
    end

    class List < Capnp::StructList
      Elem = type_member { {fixed: Annotation} }
      sig { override.returns(T.class_of(Annotation)) }
      def element_class
        Annotation
      end
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

  class CapnpVersion < Capnp::Struct
    DEFAULT_MAJOR = 0
    sig { returns(Integer) }
    def major
      read_u16(0, 0)
    end
    DEFAULT_MINOR = 0
    sig { returns(Integer) }
    def minor
      read_u8(2, 0)
    end
    DEFAULT_MICRO = 0
    sig { returns(Integer) }
    def micro
      read_u8(3, 0)
    end

    class List < Capnp::StructList
      Elem = type_member { {fixed: CapnpVersion} }
      sig { override.returns(T.class_of(CapnpVersion)) }
      def element_class
        CapnpVersion
      end
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

  class CodeGeneratorRequest < Capnp::Struct
    sig { returns(T.nilable(Schema::CapnpVersion)) }
    def capnp_version
      Schema::CapnpVersion.from_pointer(read_pointer(2))
    end
    sig { returns(T.nilable(Capnp::List[Schema::Node])) }
    def nodes
      Schema::Node::List.from_pointer(read_pointer(0))
    end
    sig { returns(T.nilable(Capnp::List[Schema::Node::SourceInfo])) }
    def source_info
      Schema::Node::SourceInfo::List.from_pointer(read_pointer(3))
    end
    sig { returns(T.nilable(Capnp::List[Schema::CodeGeneratorRequest::RequestedFile])) }
    def requested_files
      Schema::CodeGeneratorRequest::RequestedFile::List.from_pointer(read_pointer(1))
    end

    class RequestedFile < Capnp::Struct
      DEFAULT_ID = 0
      sig { returns(Integer) }
      def id
        read_u64(0, 0)
      end
      DEFAULT_FILENAME = nil
      sig { returns(T.nilable(Capnp::String)) }
      def filename
        Capnp::BufferString.from_pointer(read_pointer(0))
      end
      sig { returns(T.nilable(Capnp::List[Schema::CodeGeneratorRequest::RequestedFile::Import])) }
      def imports
        Schema::CodeGeneratorRequest::RequestedFile::Import::List.from_pointer(read_pointer(1))
      end

      class Import < Capnp::Struct
        DEFAULT_ID = 0
        sig { returns(Integer) }
        def id
          read_u64(0, 0)
        end
        DEFAULT_NAME = nil
        sig { returns(T.nilable(Capnp::String)) }
        def name
          Capnp::BufferString.from_pointer(read_pointer(0))
        end

        class List < Capnp::StructList
          Elem = type_member { {fixed: Import} }
          sig { override.returns(T.class_of(Import)) }
          def element_class
            Import
          end
        end
        sig { override.returns(Object) }
        def to_obj
          res = {}
          res["id"] = id
          res["name"] = name&.to_obj
          res
        end
      end

      class List < Capnp::StructList
        Elem = type_member { {fixed: RequestedFile} }
        sig { override.returns(T.class_of(RequestedFile)) }
        def element_class
          RequestedFile
        end
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

    class List < Capnp::StructList
      Elem = type_member { {fixed: CodeGeneratorRequest} }
      sig { override.returns(T.class_of(CodeGeneratorRequest)) }
      def element_class
        CodeGeneratorRequest
      end
    end
    sig { override.returns(Object) }
    def to_obj
      res = {}
      res["capnp_version"] = capnp_version&.to_obj
      res["nodes"] = nodes&.to_obj
      res["source_info"] = source_info&.to_obj
      res["requested_files"] = requested_files&.to_obj
      res
    end
  end
end
