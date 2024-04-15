# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::List
  extend T::Sig

  sig { params(pointer: CapnProto::Buffer::Reference).void }
  def initialize(pointer)
    # Check the type of the pointer
    offset_part = pointer.read_integer(0, true, 32)
    CapnProto::assert { offset_part & 0b11 == 1 }

    # Extract offset of data section
    offset_from_pointer = (offset_part >> 2) * CapnProto::WORD_SIZE
    data_offset = offset_from_pointer + CapnProto::WORD_SIZE

    # Extract type of list elements
    size_part = pointer.read_integer(4, false, 32)
    @element_type = T.let(size_part & 0b111, Integer)

    # Determine the length of the list
    list_size = size_part >> 3
    @length = T.let(list_size, Integer)

    # Fetch tag for composite type elements
    @data_words = T.let(0, Integer)
    @pointer_words = T.let(0, Integer)
    if @element_type == 7
      tag_pointer = pointer.apply_offset(data_offset, CapnProto::WORD_SIZE)
      @length, @data_words, @pointer_words = CapnProto::Struct.decode_pointer(tag_pointer)
      data_offset += CapnProto::WORD_SIZE
    end

    # Determine the size of the data section
    data_size = case @element_type
      # Void type elements
      when 0 then 0
      # Bit type elements
      when 1 then (list_size + 7) / 8
      # Integer type elements
      when 2, 3, 4, 5 then list_size << (@element_type - 2)
      # Pointer and Composite type elements
      else list_size * CapnProto::WORD_SIZE
    end

    @data = T.let(pointer.apply_offset(data_offset, data_size), CapnProto::Buffer::Reference)
  end

  sig { returns(Integer) }
  attr_reader :length
end

class CapnProto::String < CapnProto::List
  sig { params(pointer: CapnProto::Buffer::Reference).void }
  def initialize(pointer)
    super(pointer)
    CapnProto::assert { @element_type == 2 }
  end

  sig { returns(String) }
  def value = @data.read_string(0, @length - 1, Encoding::UTF_8)
end

class CapnProto::ListPointer
  extend T::Sig

  LIST_ELEMENT_SIZES = T.let({
    2 => 1,
    3 => 2,
    4 => 4,
    5 => 8,
  }.freeze, T::Hash[Integer, Integer])

  sig { params(segment: CapnProto::Segment, offset: Integer).void }
  def initialize(segment, offset)
    @segment = segment
    @offset = offset

    # Check the type of the pointer
    offset_part = @segment.read_integer(@offset, :s32)
    CapnProto::assert { offset_part & 0b11 == 1 }

    # Extract offset of first element
    offset_from_pointer = (offset_part >> 2) * CapnProto::WORD_SIZE
    @data_offset = T.let(@offset + offset_from_pointer + CapnProto::WORD_SIZE, Integer)

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

class CapnProto::DataPointer < CapnProto::ListPointer
  sig { params(segment: CapnProto::Segment, offset: Integer).void }
  def initialize(segment, offset)
    super(segment, offset)
    CapnProto::assert { @element_size == 1 }
  end

  sig { returns(String) }
  def value = @segment.read_string(@data_offset, @length - 1, Encoding::BINARY)
end

class CapnProto::StringPointer < CapnProto::ListPointer
  sig { params(segment: CapnProto::Segment, offset: Integer).void }
  def initialize(segment, offset)
    super(segment, offset)
    CapnProto::assert { @element_size == 1 }
  end

  sig { returns(String) }
  def value = @segment.read_string(@data_offset, @length - 1, Encoding::UTF_8)
end
