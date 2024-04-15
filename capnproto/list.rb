# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

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
