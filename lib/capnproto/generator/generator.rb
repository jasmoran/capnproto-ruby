# typed: strict

require "sorbet-runtime"
require_relative "../runtime"
require_relative "schema.capnp"

class CapnProto::Generator
  extend T::Sig

  sig { params(request_ref: CapnProto::Reference).void }
  def initialize(request_ref)
    request = Schema::CodeGeneratorRequest.from_pointer(request_ref)
    raise "Invalid CodeGeneratorRequest" if request.nil?

    nodes = request.nodes
    raise "No nodes found" if nodes.nil?

    requested_files = request.requested_files
    raise "No requested files found" if requested_files.nil?

    requested_file_ids = requested_files.map(&:id)

    # Build a hash of nodes by id and gather all requested file nodes
    @nodes_by_id = T.let({}, T::Hash[Integer, Schema::Node])
    @files = T.let([], T::Array[Schema::Node])
    nodes.each do |node|
      @nodes_by_id[node.id] = node
      if node.is_file? && requested_file_ids.include?(node.id)
        @files << node
      end
    end

    # Gather all nodes that will become classes
    @node_to_class_path = T.let({}, T::Hash[Integer, T::Array[String]])
    @files.each do |file|
      name = file_to_module_name(file)
      @node_to_class_path.merge!(find_classes(file, [name]))
    end
  end

  sig { params(node: Schema::Node, path: T::Array[String]).returns(T::Hash[Integer, T::Array[String]]) }
  def find_classes(node, path)
    # Skip constants and annotations
    return {} if node.is_const? || node.is_annotation?

    result = T.let({node.id => path}, T::Hash[Integer, T::Array[String]])

    nested_nodes = node.nested_nodes
    return result if nested_nodes.nil?

    # Recurse into nested nodes
    nested_nodes.each do |nestednode|
      name = nestednode.name&.to_s
      raise "Node without a name" if name.nil?

      new_path = path + [name]
      result.merge!(find_classes(@nodes_by_id.fetch(nestednode.id), new_path))
    end

    result
  end

  # Convert from camelCase to CapitalCase
  sig { params(name: String).returns(String) }
  def class_name(name) = "#{name[0]&.upcase}#{name[1..]}"

  # Convert from camelCase to snake_case
  sig { params(name: String).returns(String) }
  def method_name(name) = name.gsub(/([^A-Z])([A-Z]+)/, '\1_\2').downcase

  # Convert from camelCase to SCREAMING_SNAKE_CASE
  sig { params(name: String).returns(String) }
  def const_name(name) = name.gsub(/([^A-Z])([A-Z]+)/, '\1_\2').upcase

  sig { params(file: Schema::Node).returns(String) }
  def file_to_module_name(file) = class_name(file.display_name&.to_s&.split("/")&.last&.sub(".capnp", "") || "")

  sig { void }
  def generate
    @files.each do |file|
      nested_nodes = file.nested_nodes
      next "" if nested_nodes.nil?

      nested_nodes_code = nested_nodes.flat_map do |nestednode|
        name = nestednode.name&.to_s
        raise "Node without a name" if name.nil?
        node = @nodes_by_id[nestednode.id]
        raise "Node not found" if node.nil?
        process_node(name, node)
      end

      code = [
        "# typed: strict",
        "require 'sorbet-runtime'",
        "require_relative '../runtime'",
        "module #{file_to_module_name(file)}",
        *nested_nodes_code.map { "  #{_1}" },
        "end"
      ].join("\n")

      # TODO: Use RedquestedFile.filename
      path = "#{file.display_name&.to_s}.rb"
      File.write(path, code)
    end
  end

  sig { params(name: String, node: Schema::Node).returns(T::Array[String]) }
  def process_node(name, node)
    which_val = node.which?
    case which_val
    when Schema::Node::Which::Struct
      process_struct(name, node)
    when Schema::Node::Which::Enum
      process_enum(name, node)
    when Schema::Node::Which::Interface
      warn "Ignoring interface node"
      []
    when Schema::Node::Which::Const
      value = node.const.value
      raise "Const without a value" if value.nil?
      ["#{class_name(name)} = #{process_value(value)}"]
    when Schema::Node::Which::Annotation
      warn "Ignoring annotation node"
      []
    when Schema::Node::Which::File
      raise "Unexpected file node"
    else
      T.absurd(which_val)
    end
  end

  sig { params(name: String, node: Schema::Node).returns(T::Array[String]) }
  def process_struct(name, node)
    raise "Generic structs are not supported" if node.is_generic

    fields = node.struct.fields
    raise "No fields found" if fields.nil?

    field_code = fields.sort_by(&:code_order).flat_map do |field|
      process_field(field)
    end

    nested_node_code = node.nested_nodes&.flat_map do |nestednode|
      nested_node_name = nestednode.name&.to_s
      raise "Node without a name" if nested_node_name.nil?
      nested_node = @nodes_by_id.fetch(nestednode.id)

      process_node(nested_node_name, nested_node)
    end
    nested_node_code ||= []

    name = class_name(name)

    list_class_code = if node.struct.is_group
      []
    else
      [
        "  class List < CapnProto::StructList",
        "    Elem = type_member {{fixed: #{name}}}",
        "    sig { override.returns(T.class_of(#{name})) }",
        "    def element_class = #{name}",
        "  end"
      ]
    end

    # Create Which enum class for unions
    which_code = if node.struct.discriminant_count.zero?
      []
    else
      discriminant_offset = node.struct.discriminant_offset * 2
      enumerants = fields
        .reject { _1.discriminant_value == Schema::Field::NoDiscriminant }
        .sort_by(&:discriminant_value)
        .map { _1.name&.to_s || "" }
      [
        "sig { returns(Which) }",
        "def which? = Which.from_integer(read_integer(#{discriminant_offset}, false, 16, 0))",
        *process_enumeration("Which", enumerants)
      ]
    end

    # Create to_obj method
    to_obj_code = create_struct_to_obj(fields)

    [
      "class #{name} < CapnProto::Struct",
      *field_code.map { "  #{_1}" },
      *nested_node_code.map { "  #{_1}" },
      *list_class_code,
      *which_code.map { "  #{_1}" },
      *to_obj_code.map { "  #{_1}" },
      "end"
    ]
  end

  sig { params(fields: T::Enumerable[Schema::Field]).returns(T::Array[[String, String]]) }
  def create_struct_to_obj_assignments(fields)
    fields.map do |field|
      name = field.name&.to_s
      raise "Field without a name" if name.nil?

      mname = method_name(name)

      assignment = if field.is_group?
        # Group "fields" are treated as nested structs
        "res[#{mname.inspect}] = #{mname}.to_obj"
      else
        # Normal (non-group) fields
        type = field.slot.type
        raise "Field without a type" if type.nil?

        case type.which?
        when Schema::Type::Which::Text, Schema::Type::Which::Data, Schema::Type::Which::List, Schema::Type::Which::Struct
          "res[#{mname.inspect}] = #{mname}&.to_obj"
        when Schema::Type::Which::Interface, Schema::Type::Which::AnyPointer
          warn "Interfaces and AnyPointers cannot be converted to objects"
          "res[#{mname.inspect}] = #{mname}"
        else
          "res[#{mname.inspect}] = #{mname}"
        end
      end

      [name, assignment]
    end
  end

  sig { params(fields: T::Enumerable[Schema::Field]).returns(T::Array[String]) }
  def create_struct_to_obj(fields)
    # Split up union and non-union fields
    normal, union = fields
      .sort_by(&:code_order)
      .partition { _1.discriminant_value == Schema::Field::NoDiscriminant }

    # Process normal fields
    assignments = create_struct_to_obj_assignments(normal).map { "  #{_2}" }

    # Process union fields with a case statement
    union_assignments = if union.empty?
      []
    else
      whens = create_struct_to_obj_assignments(union).map do |name, assignment|
        "  when Which::#{class_name(name)} then #{assignment}"
      end
      [
        "  case which?",
        *whens,
        "  end"
      ]
    end

    [
      "sig { override.returns(Object) }",
      "def to_obj",
      "  res = {}",
      *assignments,
      *union_assignments,
      "  res",
      "end"
    ]
  end

  sig { params(field: Schema::Field).returns(T::Array[String]) }
  def process_field(field)
    # TODO: Check union discriminant values
    warn "Ignoring annotations" unless field.annotations&.length.to_i.zero?

    name = field.name&.to_s
    raise "Field without a name" if name.nil?

    mname = method_name(name)

    getter_def = if field.is_group?
      group_node = @nodes_by_id.fetch(field.group.type_id)
      class_name = "Group#{class_name(name)}"
      group_class_code = process_struct(class_name, group_node)
      [
        "sig { returns(#{class_name}) }",
        "def #{mname} = #{class_name}.new(@data, @pointers)",
        *group_class_code
      ]
    else
      type = field.slot.type
      raise "Field without a type" if type.nil?

      default_variable = "DEFAULT_#{const_name(name)}"

      which_type = type.which?
      case which_type
      when Schema::Type::Which::Void
        [
          "sig { returns(NilClass) }",
          "def #{mname} = nil"
        ]
      when Schema::Type::Which::Bool
        default_value = field.slot.default_value&.bool ? "0xFF" : "0x00"
        offset = field.slot.offset / 8
        mask = (1 << (field.slot.offset % 8)).to_s(16)
        [
          "#{default_variable} = #{field.slot.default_value&.bool == true}",
          "sig { returns(T::Boolean) }",
          "def #{mname} = (read_integer(#{offset}, false, 8, #{default_value}) & 0x#{mask}) != 0"
        ]
      when Schema::Type::Which::Int8
        default_value = field.slot.default_value&.int8 || 0
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Integer) }",
          "def #{mname} = read_integer(#{field.slot.offset}, true, 8, #{default_value})"
        ]
      when Schema::Type::Which::Int16
        default_value = field.slot.default_value&.int16 || 0
        offset = field.slot.offset * 2
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Integer) }",
          "def #{mname} = read_integer(#{offset}, true, 16, #{default_value})"
        ]
      when Schema::Type::Which::Int32
        default_value = field.slot.default_value&.int32 || 0
        offset = field.slot.offset * 4
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Integer) }",
          "def #{mname} = read_integer(#{offset}, true, 32, #{default_value})"
        ]
      when Schema::Type::Which::Int64
        default_value = field.slot.default_value&.int64 || 0
        offset = field.slot.offset * 8
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Integer) }",
          "def #{mname} = read_integer(#{offset}, true, 64, #{default_value})"
        ]
      when Schema::Type::Which::Uint8
        default_value = field.slot.default_value&.uint8 || 0
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Integer) }",
          "def #{mname} = read_integer(#{field.slot.offset}, false, 8, #{default_value})"
        ]
      when Schema::Type::Which::Uint16
        default_value = field.slot.default_value&.uint16 || 0
        offset = field.slot.offset * 2
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Integer) }",
          "def #{mname} = read_integer(#{offset}, false, 16, #{default_value})"
        ]
      when Schema::Type::Which::Uint32
        default_value = field.slot.default_value&.uint32 || 0
        offset = field.slot.offset * 4
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Integer) }",
          "def #{mname} = read_integer(#{offset}, false, 32, #{default_value})"
        ]
      when Schema::Type::Which::Uint64
        default_value = field.slot.default_value&.uint64 || 0
        offset = field.slot.offset * 8
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Integer) }",
          "def #{mname} = read_integer(#{offset}, false, 64, #{default_value})"
        ]
      when Schema::Type::Which::Float32
        default_value = field.slot.default_value&.float32 || 0.0
        offset = field.slot.offset * 4
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Float) }",
          "def #{mname} = read_float(#{offset}, 32, #{default_value})"
        ]
      when Schema::Type::Which::Float64
        default_value = field.slot.default_value&.float64 || 0.0
        offset = field.slot.offset * 8
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(Float) }",
          "def #{mname} = read_float(#{offset}, 64, #{default_value})"
        ]
      when Schema::Type::Which::Text
        default_value = field.slot.default_value&.text&.to_s.inspect
        apply_default = field.slot.had_explicit_default ? " || CapnProto::ObjectString.new(#{default_variable})" : ""
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(T.nilable(CapnProto::String)) }",
          "def #{mname} = CapnProto::BufferString.from_pointer(read_pointer(#{field.slot.offset}))#{apply_default}"
        ]
      when Schema::Type::Which::Data
        default_value = field.slot.default_value&.data&.value.inspect
        apply_default = field.slot.had_explicit_default ? " || #{default_variable}" : ""
        [
          "#{default_variable} = #{default_value}",
          "sig { returns(T.nilable(CapnProto::Data)) }",
          "def #{mname} = CapnProto::Data.from_pointer(read_pointer(#{field.slot.offset}))#{apply_default}"
        ]
      when Schema::Type::Which::List
        raise "List default values not supported" if field.slot.had_explicit_default
        element_class = type.list.element_type
        raise "List without an element type" if element_class.nil?
        which_element_type = element_class.which?
        case which_element_type
        when Schema::Type::Which::Void
          raise "Void list elements not supported"
        when Schema::Type::Which::Bool
          raise "Bool list elements not supported"
        when Schema::Type::Which::Int8, Schema::Type::Which::Int16, Schema::Type::Which::Int32, Schema::Type::Which::Int64
          list_class = "CapnProto::SignedIntegerList"
          element_class = "Integer"
        when Schema::Type::Which::Uint8, Schema::Type::Which::Uint16, Schema::Type::Which::Uint32, Schema::Type::Which::Uint64
          list_class = "CapnProto::UnsignedIntegerList"
          element_class = "Integer"
        when Schema::Type::Which::Float32, Schema::Type::Which::Float64
          list_class = "CapnProto::FloatList"
          element_class = "Float"
        when Schema::Type::Which::Text
          raise "Text list elements not supported"
        when Schema::Type::Which::Data
          raise "Data list elements not supported"
        when Schema::Type::Which::List
          raise "List list elements not supported"
        when Schema::Type::Which::Enum
          raise "Enum list elements not supported"
        when Schema::Type::Which::Struct
          raise "List[Struct] default values not supported" if field.slot.had_explicit_default
          element_class = @node_to_class_path.fetch(element_class.struct.type_id).join("::")
          list_class = "#{element_class}::List"
        when Schema::Type::Which::Interface
          raise "Interface list elements not supported"
        when Schema::Type::Which::AnyPointer
          raise "AnyPointer list elements not supported"
        else
          T.absurd(which_element_type)
        end

        [
          "sig { returns(T.nilable(CapnProto::List[#{element_class}])) }",
          "def #{mname} = #{list_class}.from_pointer(read_pointer(#{field.slot.offset}))"
        ]
      when Schema::Type::Which::Enum
        enumerants = @nodes_by_id.fetch(type.enum.type_id).enum.enumerants
        raise "No enumerants found" if enumerants.nil?

        default_num = field.slot.default_value&.enum || 0
        default_value = class_name(enumerants[default_num]&.name&.to_s || "")

        offset = field.slot.offset * 2
        class_path = @node_to_class_path.fetch(type.enum.type_id).join("::")
        [
          # TODO: This doesn't work if the enum class is declared after this field
          "# #{default_variable} = #{class_path}::#{default_value}",
          "sig { returns(#{class_path}) }",
          "def #{mname} = #{class_path}.from_integer(read_integer(#{offset}, false, 16, #{default_num}))"
        ]
      when Schema::Type::Which::Struct
        raise "Struct default values not supported" if field.slot.had_explicit_default
        class_path = @node_to_class_path.fetch(type.struct.type_id).join("::")
        [
          "sig { returns(T.nilable(#{class_path})) }",
          "def #{mname} = #{class_path}.from_pointer(read_pointer(#{field.slot.offset}))"
        ]
      when Schema::Type::Which::Interface
        raise "Interface fields not supported"
      when Schema::Type::Which::AnyPointer
        raise "Only unconstrained AnyPointers are supported" unless type.any_pointer.is_unconstrained?
        [
          "sig { returns(CapnProto::Reference) }",
          "def #{mname} = read_pointer(#{field.slot.offset})"
        ]
      else
        T.absurd(which_type)
      end
    end

    # Add type checking methods for union fields
    if field.discriminant_value != Schema::Field::NoDiscriminant
      getter_def += [
        "sig { returns(T::Boolean) }",
        "def is_#{mname}? = which? == Which::#{class_name(name)}"
      ]
    end

    getter_def
  end

  sig { params(name: String, node: Schema::Node).returns(T::Array[String]) }
  def process_enum(name, node)
    raise "Nested nodes not supported in enum" unless node.nested_nodes&.length.to_i.zero?
    raise "Generic structs are not supported" if node.is_generic

    enumerants = node.enum.enumerants
    raise "No enumerants found" if enumerants.nil?

    # Enumerants are ordered by their numeric value
    enums = enumerants.map do |enumerant|
      warn "Ignoring annotations" unless enumerant.annotations&.length.to_i.zero?

      enumerant_name = enumerant.name&.to_s
      raise "Enumerant without a name" if enumerant_name.nil?
      enumerant_name
    end

    process_enumeration(name, enums)
  end

  sig { params(name: String, enumerants: T::Array[String]).returns(T::Array[String]) }
  def process_enumeration(name, enumerants)
    definitions = T.let([], T::Array[String])
    from_int = T.let([], T::Array[String])

    # Enumerants are ordered by their numeric value
    enumerants.each_with_index do |enumerant_name, ix|
      ename = class_name(enumerant_name)
      definitions << "    #{ename} = new(#{enumerant_name.inspect})"
      from_int << "    when #{ix} then #{ename}"
    end

    # TODO: Define an CapnProto::Enum class
    class_name = class_name(name)
    [
      "class #{class_name} < T::Enum",
      "  extend T::Sig",
      "  enums do",
      *definitions,
      "  end",
      "  sig { params(value: Integer).returns(#{class_name}) }",
      "  def self.from_integer(value)",
      "    case value",
      *from_int,
      "    else raise \"Unknown #{name} value: \#{value}\"",
      "    end",
      "  end",
      "end"
    ]
  end

  sig { params(value: Schema::Value).returns(T.any(String, T::Boolean, Numeric, NilClass)) }
  def process_value(value)
    which_value = value.which?
    case which_value
    when Schema::Value::Which::Void then nil
    when Schema::Value::Which::Bool then value.bool
    when Schema::Value::Which::Int8 then value.int8
    when Schema::Value::Which::Int16 then value.int16
    when Schema::Value::Which::Int32 then value.int32
    when Schema::Value::Which::Int64 then value.int64
    when Schema::Value::Which::Uint8 then value.uint8
    when Schema::Value::Which::Uint16 then value.uint16
    when Schema::Value::Which::Uint32 then value.uint32
    when Schema::Value::Which::Uint64 then value.uint64
    when Schema::Value::Which::Float32 then value.float32
    when Schema::Value::Which::Float64 then value.float64
    when Schema::Value::Which::Text then value.text&.to_s.inspect
    when Schema::Value::Which::Data then value.data&.value.inspect
    when Schema::Value::Which::List then raise "List values not supported"
    when Schema::Value::Which::Enum then value.enum # TODO: Convert to enum class
    when Schema::Value::Which::Struct then raise "Struct values not supported"
    when Schema::Value::Which::Interface then nil
    when Schema::Value::Which::AnyPointer then raise "AnyPointer values not supported"
    else T.absurd(which_value)
    end
  end
end
