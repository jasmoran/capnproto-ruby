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
      file.nestedNodes&.each do |node|
        pp nodes_by_id[node.id].to_h
      end
    end

    ''
  end

end
