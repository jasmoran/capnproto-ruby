# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "message"

class Capnp::StreamMessage < Capnp::Message
  extend T::Sig

  sig { params(buffer: Capnp::SliceableBuffer).void }
  def initialize(buffer)
    # Extract number of segments
    number_of_segments = buffer.read_u32(0) + 1

    # Calculate size of the message header
    offset = 4 * (number_of_segments + 1)
    offset += 4 if number_of_segments.even?

    # Check that the buffer is large enough for all segment sizes
    raise Capnp::Error.new("Not enough segment sizes provided") if buffer.size <= offset

    # Create segments
    segments = (1..number_of_segments).map do |ix|
      # Get segment size in bytes
      segment_size = buffer.read_u32(ix * 4) * Capnp::WORD_SIZE

      # Check that the buffer is large enough for the segment
      raise Capnp::Error.new("Buffer smaller than provided segment sizes") if buffer.size < offset + segment_size

      # Create segment
      slice = buffer.slice(offset, segment_size)
      segment = Capnp::Segment.new(self, slice)

      offset += segment_size
      segment
    end

    @segments = T.let(segments, T::Array[Capnp::Segment])
  end

  sig { returns(T::Array[Capnp::Segment]) }
  attr_reader :segments

  sig { override.params(id: Integer).returns(Capnp::Segment) }
  def segment(id)
    segment = @segments[id]
    raise Capnp::Error.new("Unknown Segment ID #{id}") if segment.nil?
    segment
  end
end
