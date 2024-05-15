# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "message"
require_relative "../segment"

class Capnp::FlatMessage < Capnp::Message
  extend T::Sig

  sig { params(segment: Capnp::Buffer).void }
  def initialize(segment)
    @segment = T.let(Capnp::Segment.new(self, segment), Capnp::Segment)
  end

  sig { override.params(id: Integer).returns(Capnp::Segment) }
  def segment(id)
    raise Capnp::Error.new("Unknown Segment ID #{id}") unless id.zero?
    @segment
  end
end
