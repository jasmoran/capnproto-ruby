#!/usr/bin/env ruby

def assert
  raise 'Assertion failed' unless yield
end

WORD_SIZE = 8

class StructPointer
  def initialize(segment, offset)
    @segment = segment
    @offset = offset

    # Check the type of the pointer
    assert { @segment.value(@offset, :U8) & 0b1100_0000 == 0 }

    # Extract offset of data section and perform sign extention
    data_offset = @segment.value(@offset, :u32)
    data_offset = (data_offset ^ 0x20000000) - 0x20000000

    # Extract size of data and pointer sections
    @data_size = @segment.value(@offset + 4, :u16) * WORD_SIZE
    @pointer_size = @segment.value(@offset + 6, :u16) * WORD_SIZE

    # Calculate offsets of data and pointer sections
    @data_offset = @offset + data_offset + WORD_SIZE
    @pointer_offset = @data_offset + @data_size
  end

  def read(offset, size) = @segment.read(@data_offset + offset, size)
  def value(offset, type) = @segment.value(@data_offset + offset, type)
  def pointer(ix) = @segment.read(@pointer_offset + WORD_SIZE * 8, WORD_SIZE)
end

class Segment
  def initialize(message, offset, size)
    @message = message
    @offset = offset
    @size = size
  end

  def read(offset, size) = @message.read(@offset + offset, size)
  def value(offset, type) = @message.value(@offset + offset, type)
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
    @segments = (1..number_of_segments).map do |ix|
      # Get segment size in words
      segment_size = @buffer.get_value(:u32, ix * 4) * WORD_SIZE
      segment = Segment.new(self, offset, segment_size)
      offset += segment_size
      segment
    end
  end

  def read(offset, size) = @buffer.get_string(offset, size)
  def value(offset, type) = @buffer.get_value(type, offset)
  def root = @segments.first
end

class Person < StructPointer
  DEFAULT_PHONES = 8
  def birthdate = value(4, :s32)
  def phones = value(0, :s16) ^ DEFAULT_PHONES
  def to_h = {
    name: nil,
    birthdate: birthdate,
    email: nil,
    phones: phones,
  }
end

if __FILE__ == $PROGRAM_NAME
  require 'pp'
  buffer = IO::Buffer.for(STDIN.read)
  message = Message.new(buffer)
  sp = Person.new(message.root, 0)
  pp sp
  pp sp.to_h
  buffer.free
end
