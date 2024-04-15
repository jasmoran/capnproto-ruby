# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'
require_relative 'capnproto/buffer'

class CapnProto::Message < CapnProto::Buffer
  extend T::Sig

  sig { params(buffer: IO::Buffer, offset: Integer, size: Integer).void }
  def initialize(buffer, offset, size)
    super(buffer, offset, size)

    # Extract number of segments
    number_of_segments = read_integer(0, false, 32) + 1

    # Calculate size of the message header
    offset = 4 * (number_of_segments + 1)
    offset += 4 if number_of_segments.even?

    # Create segments
    segments = (1..number_of_segments).map do |ix|
      # Get segment size in bytes
      segment_size = read_integer(ix * 4, false, 32) * CapnProto::WORD_SIZE

      # Create segment
      segment = apply_offset(offset, segment_size)

      offset += segment_size
      segment
    end
    @segments = T.let(segments, T::Array[CapnProto::Message])
  end

  sig { returns(T.nilable(CapnProto::Message)) }
  def root = @segments.first&.apply_offset(0, CapnProto::WORD_SIZE)
end
