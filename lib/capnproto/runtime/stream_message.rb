# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "message"

class CapnProto::StreamMessage < CapnProto::Message
  extend T::Sig

  sig { params(buffer: CapnProto::SliceableBuffer).void }
  def initialize(buffer)
    # Extract number of segments
    number_of_segments = buffer.read_integer(0, false, 32) + 1

    # Calculate size of the message header
    offset = 4 * (number_of_segments + 1)
    offset += 4 if number_of_segments.even?

    # Check that the buffer is large enough for all segment sizes
    raise CapnProto::Error.new("Not enough segment sizes provided") if buffer.size <= offset

    # Create segments
    segments = (1..number_of_segments).map do |ix|
      # Get segment size in bytes
      segment_size = buffer.read_integer(ix * 4, false, 32) * CapnProto::WORD_SIZE

      # Check that the buffer is large enough for the segment
      raise CapnProto::Error.new("Buffer smaller than provided segment sizes") if buffer.size < offset + segment_size

      # Create segment
      slice = buffer.slice(offset, segment_size)
      segment = CapnProto::Segment.new(self, slice)

      offset += segment_size
      segment
    end

    @segments = T.let(segments, T::Array[CapnProto::Segment])
  end

  sig { returns(T::Array[CapnProto::Segment]) }
  attr_reader :segments

  sig { override.params(id: Integer).returns(CapnProto::Segment) }
  def segment(id)
    segment = @segments[id]
    raise CapnProto::Error.new("Unknown Segment ID #{id}") if segment.nil?
    segment
  end
end
