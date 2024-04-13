#!/usr/bin/env ruby

class Segment
  def initialize(message, offset, size)
    @message = message
    @offset = offset
    @size = size
  end
end

class Message
  def initialize(io)
    @io = io

    # Extract massage header information
    number_of_segments = @io.read(4).unpack1("L<") + 1
    segment_sizes = @io.read(number_of_segments * 4).unpack("L<*")

    # Calculate size of the message header
    offset = 4 * (number_of_segments + 1)
    offset += 4 if number_of_segments.even?

    # Create segments
    @segments = segment_sizes.map do |size|
      size *= 8
      segment = Segment.new(@io, offset, size)
      offset += size
      segment
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'pp'
  pp Message.new(STDIN)
end
