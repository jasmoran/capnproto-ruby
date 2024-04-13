#!/usr/bin/env ruby

def assert
  raise 'Assertion failed' unless yield
end

WORD_SIZE = 8
LIST_ELEMENT_SIZES = {
  2 => 1,
  3 => 2,
  4 => 4,
  5 => 8,
}.freeze

class StructPointer
  def initialize(segment, offset)
    @segment = segment
    @offset = offset

    # Check the type of the pointer
    offset_part = @segment.value(@offset, :u32)
    assert { offset_part & 0b11 == 0 }

    # Extract offset of data section
    offset_from_pointer = (offset_part & 0xFFFFFFFC) * 2
    @data_offset = @offset + offset_from_pointer + WORD_SIZE

    # Extract size of data and pointer sections
    @data_size = @segment.value(@offset + 4, :u16) * WORD_SIZE
    @pointer_size = @segment.value(@offset + 6, :u16) * WORD_SIZE

    # Calculate offset of pointer section
    @pointer_offset = @data_offset + @data_size
  end

  def read(offset, size) = @segment.read(@data_offset + offset, size)
  def value(offset, type) = @segment.value(@data_offset + offset, type)
  def pointer_offset(ix) = @pointer_offset + ix * WORD_SIZE
end

class ListPointer
  def initialize(segment, offset)
    @segment = segment
    @offset = offset

    # Check the type of the pointer
    offset_part = @segment.value(@offset, :u32)
    assert { offset_part & 0b11 == 1 }

    # Extract offset of first element
    offset_from_pointer = (offset_part & 0xFFFFFFFC) * 2
    @data_offset = @offset + offset_from_pointer + WORD_SIZE

    # Extract type of list elements
    size_part = @segment.value(@offset + 4, :u32)
    element_type = size_part & 0b111
    @element_size = LIST_ELEMENT_SIZES[element_type]
    raise "Unsupported list element type #{element_type}" if @element_size.nil?

    # Extract number of elements
    @length = (size_part & 0xFFFF_FFF8) / 8
  end

  attr_reader :length

  def get(ix, type) = @segment.value(@data_offset + ix * @element_size, type)
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
