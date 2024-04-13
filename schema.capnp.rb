#!/usr/bin/env ruby

class Segment
  def initialize(message, offset, size)
    @message = message
    @offset = offset
    @size = size
  end
end

class Message
  def initialize(buffer)
    @buffer = buffer

    # Extract number of segments
    number_of_segments = @buffer.get_value(:u32, 0) + 1

    # Calculate size of the message header
    offset = 4 * (number_of_segments + 1)
    offset += 4 if number_of_segments.even?

    # Create segments
    @segments = (1..number_of_segments).map do |offset|
      # Get segment size in words
      segment_size = @buffer.get_value(:u32, offset * 4) * 8
      segment = Segment.new(self, offset, segment_size)
      offset += segment_size
      segment
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'pp'
  buffer = IO::Buffer.for(STDIN.read)
  pp Message.new(buffer)
  buffer.free
end
