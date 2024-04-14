#!/usr/bin/env ruby
# typed: strict
extend T::Sig

sig { params(block: T.proc.returns(T::Boolean)).void }
def assert(&block)
  raise 'Assertion failed' unless yield
end

WORD_SIZE = 8
LIST_ELEMENT_SIZES = T.let({
  2 => 1,
  3 => 2,
  4 => 4,
  5 => 8,
}.freeze, T::Hash[Integer, Integer])

class StructPointer
  extend T::Sig

  sig { params(segment: Segment, offset: Integer).void }
  def initialize(segment, offset)
    @segment = segment
    @offset = offset

    # Check the type of the pointer
    offset_part = @segment.read_integer(@offset, :u32)
    assert { offset_part & 0b11 == 0 }

    # Extract offset of data section
    offset_from_pointer = (offset_part & 0xFFFFFFFC) * 2
    @data_offset = T.let(@offset + offset_from_pointer + WORD_SIZE, Integer)

    # Extract size of data and pointer sections
    @data_size = T.let(@segment.read_integer(@offset + 4, :u16) * WORD_SIZE, Integer)
    @pointer_size = T.let(@segment.read_integer(@offset + 6, :u16) * WORD_SIZE, Integer)

    # Calculate offset of pointer section
    @pointer_offset = T.let(@data_offset + @data_size, Integer)
  end

  sig { params(offset: Integer, size: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, size, encoding) = @segment.read_string(@data_offset + offset, size, encoding)

  sig { params(offset: Integer, type: Symbol).returns(Integer) }
  def read_integer(offset, type) = @segment.read_integer(@data_offset + offset, type)

  sig { params(ix: Integer).returns(Integer) }
  def pointer_offset(ix) = @pointer_offset + ix * WORD_SIZE
end

class ListPointer
  extend T::Sig

  sig { params(segment: Segment, offset: Integer).void }
  def initialize(segment, offset)
    @segment = segment
    @offset = offset

    # Check the type of the pointer
    offset_part = @segment.read_integer(@offset, :u32)
    assert { offset_part & 0b11 == 1 }

    # Extract offset of first element
    offset_from_pointer = (offset_part & 0xFFFFFFFC) * 2
    @data_offset = T.let(@offset + offset_from_pointer + WORD_SIZE, Integer)

    # Extract type of list elements
    size_part = @segment.read_integer(@offset + 4, :u32)
    element_type = size_part & 0b111
    element_size = LIST_ELEMENT_SIZES[element_type]
    raise "Unsupported list element type #{element_type}" if element_size.nil?
    @element_size = T.let(element_size, Integer)

    # Extract number of elements
    @length = T.let((size_part & 0xFFFF_FFF8) / 8, Integer)
  end

  sig { returns(Integer) }
  attr_reader :length

  sig { params(ix: Integer, type: Symbol).returns(Integer) }
  def get(ix, type) = @segment.read_integer(@data_offset + ix * @element_size, type)
end

class DataPointer < ListPointer
  sig { params(segment: Segment, offset: Integer).void }
  def initialize(segment, offset)
    super(segment, offset)
    assert { @element_size == 1 }
  end

  sig { returns(String) }
  def value = @segment.read_string(@data_offset, @length - 1, Encoding::BINARY)
end

class StringPointer < ListPointer
  sig { params(segment: Segment, offset: Integer).void }
  def initialize(segment, offset)
    super(segment, offset)
    assert { @element_size == 1 }
  end

  sig { returns(String) }
  def value = @segment.read_string(@data_offset, @length - 1, Encoding::UTF_8)
end

class Segment
  extend T::Sig

  sig { params(message: Message, offset: Integer, size: Integer).void }
  def initialize(message, offset, size)
    @message = message
    @offset = offset
    @size = size
  end

  sig { params(offset: Integer, size: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, size, encoding) = @message.read_string(@offset + offset, size, encoding)

  sig { params(offset: Integer, type: Symbol).returns(Integer) }
  def read_integer(offset, type) = @message.read_integer(@offset + offset, type)
end

class Message
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
      segment_size = read_integer(ix * 4, :u32) * WORD_SIZE
      segment = Segment.new(self, offset, segment_size)
      offset += segment_size
      segment
    end
    @segments = T.let(segments, T::Array[Segment])
  end

  sig { params(offset: Integer, size: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, size, encoding) = @buffer.get_string(offset, size, encoding)

  sig { params(offset: Integer, type: Symbol).returns(Integer) }
  def read_integer(offset, type) = T.cast(@buffer.get_value(type, offset), Integer)

  sig { returns(T.nilable(Segment)) }
  def root = @segments.first
end

module Test
  class Date < StructPointer
    sig { returns(Integer) }
    def year = read_integer(0, :u16)

    sig { returns(Integer) }
    def month = read_integer(2, :U8)

    sig { returns(Integer) }
    def day = read_integer(3, :U8)

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      year: year,
      month: month,
      day: day,
    }
  end

  class Person < StructPointer
    DEFAULT_PHONES = 8

    sig { returns(String)}
    def name = StringPointer.new(@segment, pointer_offset(0)).value

    sig { returns(Test::Date) }
    def birthdate = Date.new(@segment, pointer_offset(2))

    sig { returns(String) }
    def email = StringPointer.new(@segment, pointer_offset(1)).value

    sig { returns(Integer) }
    def phones = read_integer(0, :s16) ^ DEFAULT_PHONES

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      name: name,
      birthdate: birthdate.to_h,
      email: email,
      phones: phones,
    }
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'pp'
  buffer = IO::Buffer.for(STDIN.read)
  message = Message.new(buffer)
  root = message.root
  exit if root.nil?
  sp = Test::Person.new(root, 0)
  pp sp.to_h
  buffer.free
end
