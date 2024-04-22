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
    warn 'Ignoring nodes nested in struct' unless node.nestedNodes&.length&.nonzero?
    raise 'Generic structs are not supported' if node.isGeneric

    fields = node.struct.fields
    raise 'No fields found' if fields.nil?

    fields.sort_by(&:codeOrder).each do |field|
      pp field.to_h
    end
  end
end
