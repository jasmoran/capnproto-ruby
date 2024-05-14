# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "message"
require_relative "../segment"

class CapnProto::FlatMessage < CapnProto::Message
  extend T::Sig

  sig { params(segment: CapnProto::Buffer).void }
  def initialize(segment)
    @segment = T.let(CapnProto::Segment.new(self, segment), CapnProto::Segment)
  end

  sig { override.params(id: Integer).returns(CapnProto::Segment) }
  def segment(id)
    raise CapnProto::Error.new("Unknown Segment ID #{id}") unless id.zero?
    @segment
  end
end
