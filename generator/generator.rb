# typed: strict

require 'sorbet-runtime'
require_relative '../capnproto'
require_relative 'schema.capnp'

class CapnProto::Generator
  extend T::Sig

  sig { params(input: String).returns(String) }
  def self.generate(input)
    schema_message = CapnProto::Message.from_string(input)
    schema = Schema::CodeGeneratorRequest.from_pointer(schema_message.root)
    raise 'Invalid schema' if schema.nil?

    nodes = schema.nodes
    raise 'No nodes found' if nodes.nil?

    requested_files = schema.requestedFiles
    raise 'No requested files found' if requested_files.nil?

    requested_file_ids = requested_files.map(&:id)

    # Build a hash of nodes by id and gather all requested file nodes
    nodes_by_id = T.let({}, T::Hash[Integer, Schema::Node])
    files = T.let([], T::Array[Schema::Node])
    nodes.each do |node|
      nodes_by_id[node.id] = node
      if node.which == Schema::Node::Which::File && requested_file_ids.include?(node.id)
        files << node
      end
    end

    files.each do |file|
      file.nestedNodes&.each do |nestednode|
        name = nestednode.name
        raise 'Node without a name' if name.nil?
        node = nodes_by_id[nestednode.id]
        raise 'Node not found' if node.nil?
        process_node(name.value, node)
      end
    end

    ''
  end

  sig { params(name: String, node: Schema::Node).void }
  def self.process_node(name, node)
    which_val = node.which
    case which_val
    when Schema::Node::Which::Struct
      process_struct(node)
    when Schema::Node::Which::Enum
      warn 'Ignoring enum node'
    when Schema::Node::Which::Interface
      warn 'Ignoring interface node'
    when Schema::Node::Which::Const
      warn 'Ignoring const node'
    when Schema::Node::Which::Annotation
      warn 'Ignoring annotation node'
    when Schema::Node::Which::File
      raise 'Unexpected file node'
    else
      T.absurd(which_val)
    end
  end

  sig { params(node: Schema::Node).void }
  def self.process_struct(node)
    warn 'Ignoring nodes nested in struct' unless node.nestedNodes&.length.to_i.zero?
    raise 'Generic structs are not supported' if node.isGeneric

    fields = node.struct.fields
    raise 'No fields found' if fields.nil?

    fields.sort_by(&:codeOrder).each do |field|
      pp process_field(field)
    end
  end

  sig { params(field: Schema::Field).returns(T::Array[String]) }
  def self.process_field(field)
    raise 'Groups not supported' if field.which == Schema::Field::Which::Group
    warn 'Ignoring annotations' unless field.annotations&.length.to_i.zero?
    raise 'Unions not supported' if field.discriminantValue != 0xFFFF
    name = field.name&.value
    raise 'Field without a name' if name.nil?
    type = field.slot.type
    raise 'Field without a type' if type.nil?

    default_variable = "DEFAULT_#{name.upcase}"

    case type.which
    when Schema::Type::Which::Void
      ['sig { void }', "def #{name}; end"]
    when Schema::Type::Which::Bool
      default_value = field.slot.defaultValue&.bool ? '0xFF' : '0x00'
      offset = field.slot.offset / 8
      mask = (1 << (field.slot.offset % 8)).to_s(16)
      [
        "#{default_variable} = #{field.slot.defaultValue&.bool == true}",
        'sig { returns(T::Boolean) }',
        "def #{name} = (read_integer(#{offset}, false, 8, #{default_value}) & 0x#{mask}) != 0"
      ]
    when Schema::Type::Which::Int8
      default_value = field.slot.defaultValue&.int8 || 0
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Integer) }',
        "def #{name} = read_integer(#{field.slot.offset}, true, 8, #{default_value})"
      ]
    when Schema::Type::Which::Int16
      default_value = field.slot.defaultValue&.int16 || 0
      offset = field.slot.offset * 2
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Integer) }',
        "def #{name} = read_integer(#{offset}, true, 16, #{default_value})"
      ]
    when Schema::Type::Which::Int32
      default_value = field.slot.defaultValue&.int32 || 0
      offset = field.slot.offset * 4
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Integer) }',
        "def #{name} = read_integer(#{offset}, true, 32, #{default_value})"
      ]
    when Schema::Type::Which::Int64
      default_value = field.slot.defaultValue&.int64 || 0
      offset = field.slot.offset * 8
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Integer) }',
        "def #{name} = read_integer(#{offset}, true, 64, #{default_value})"
      ]
    when Schema::Type::Which::Uint8
      default_value = field.slot.defaultValue&.uint8 || 0
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Integer) }',
        "def #{name} = read_integer(#{field.slot.offset}, false, 8, #{default_value})"
      ]
    when Schema::Type::Which::Uint16
      default_value = field.slot.defaultValue&.uint16 || 0
      offset = field.slot.offset * 2
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Integer) }',
        "def #{name} = read_integer(#{offset}, false, 16, #{default_value})"
      ]
    when Schema::Type::Which::Uint32
      default_value = field.slot.defaultValue&.uint32 || 0
      offset = field.slot.offset * 4
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Integer) }',
        "def #{name} = read_integer(#{offset}, false, 32, #{default_value})"
      ]
    when Schema::Type::Which::Uint64
      default_value = field.slot.defaultValue&.uint64 || 0
      offset = field.slot.offset * 8
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Integer) }',
        "def #{name} = read_integer(#{offset}, false, 64, #{default_value})"
      ]
    when Schema::Type::Which::Float32
      default_value = field.slot.defaultValue&.float32 || 0.0
      offset = field.slot.offset * 4
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Float) }',
        "def #{name} = read_float(#{offset}, 32, #{default_value})"
      ]
    when Schema::Type::Which::Float64
      default_value = field.slot.defaultValue&.float64 || 0.0
      offset = field.slot.offset * 8
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(Float) }',
        "def #{name} = read_float(#{offset}, 64, #{default_value})"
      ]
    when Schema::Type::Which::Text
      default_value = field.slot.defaultValue&.text&.value.inspect
      apply_default = field.slot.hadExplicitDefault ? " || #{default_variable}" : ''
      [
        "#{default_variable} = #{default_value}",
        'sig { returns(T.nilable(CapnProto::String)) }',
        "def #{name} = CapnProto::String.from_pointer(read_pointer(#{field.slot.offset}))#{apply_default}"
      ]
    else
      pp field.to_h
      []
    end
  end
end
