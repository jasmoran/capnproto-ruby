# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::Message
  extend T::Sig

  sig { params(buffer: IO::Buffer).void }
  def initialize(buffer)
    @buffer = buffer

    # Extract number of segments
    number_of_segments = read_integer(0, :u32) + 1

    # Calculate size of the message header
    offset = 4 * (number_of_segments + 1)
    offset += 4 if number_of_segments.even?

    # Create segments
    segments = (1..number_of_segments).map do |ix|
      # Get segment size in words
      segment_size = read_integer(ix * 4, :u32) * CapnProto::WORD_SIZE
      segment = CapnProto::Segment.new(self, offset, segment_size)
      offset += segment_size
      segment
    end
    @segments = T.let(segments, T::Array[CapnProto::Segment])
  end

  sig { params(offset: Integer, size: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, size, encoding) = @buffer.get_string(offset, size, encoding)

  sig { params(offset: Integer, type: Symbol).returns(Integer) }
  def read_integer(offset, type) = T.cast(@buffer.get_value(type, offset), Integer)

  sig { returns(T.nilable(CapnProto::Segment)) }
  def root = @segments.first
end
