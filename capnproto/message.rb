# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::Message
  extend T::Sig

  sig { params(buffer: CapnProto::Buffer).void }
  def initialize(buffer)
    @buffer = buffer

    # Extract number of segments
    number_of_segments = buffer.read_integer(0, :u32) + 1

    # Calculate size of the message header
    offset = 4 * (number_of_segments + 1)
    offset += 4 if number_of_segments.even?

    # Create segments
    segments = (1..number_of_segments).map do |ix|
      # Get segment size in bytes
      segment_size = buffer.read_integer(ix * 4, :u32) * CapnProto::WORD_SIZE

      # Create segment
      segment = buffer.slice(offset, segment_size)

      offset += segment_size
      segment
    end
    @segments = T.let(segments, T::Array[CapnProto::Buffer])
  end

  sig { returns(T.nilable(CapnProto::Buffer)) }
  def root = @segments.first
end
