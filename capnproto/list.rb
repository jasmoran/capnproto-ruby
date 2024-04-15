# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::List
  extend T::Sig

  private

  sig do
    params(
      data: CapnProto::Buffer,
      length: Integer,
      element_type: Integer,
      data_words: Integer,
      pointer_words: Integer
    ).void
  end
  def initialize(data, length, element_type, data_words, pointer_words)
    @data = data
    @length = length
    @element_type = element_type
    @data_words = data_words
    @pointer_words = pointer_words
  end

  public

  sig { params(pointer: CapnProto::Buffer).returns(T.nilable(T.attached_class)) }
  def self.from_pointer(pointer)
    pointer_value = pointer.read_integer(0, false, 64)
    return if pointer_value.zero?

    # Check the type of the pointer
    offset_part = pointer.read_integer(0, true, 32)
    CapnProto::assert { offset_part & 0b11 == 1 }

    # Extract offset of data section
    offset_from_pointer = (offset_part >> 2) * CapnProto::WORD_SIZE
    data_offset = offset_from_pointer + CapnProto::WORD_SIZE

    # Extract type of list elements
    size_part = pointer.read_integer(4, false, 32)
    element_type = size_part & 0b111

    # Determine the length of the list
    list_size = size_part >> 3
    length = list_size

    # Fetch tag for composite type elements
    data_words = 0
    pointer_words = 0
    if element_type == 7
      tag_pointer = pointer.apply_offset(data_offset, CapnProto::WORD_SIZE)
      length, data_words, pointer_words = CapnProto::Struct.decode_pointer(tag_pointer)
      data_offset += CapnProto::WORD_SIZE
    end

    # Determine the size of the data section
    data_size = case element_type
      # Void type elements
      when 0 then 0
      # Bit type elements
      when 1 then (list_size + 7) / 8
      # Integer type elements
      when 2, 3, 4, 5 then list_size << (element_type - 2)
      # Pointer and Composite type elements
      else list_size * CapnProto::WORD_SIZE
    end

    data = pointer.apply_offset(data_offset, data_size)

    self.new(data, length, element_type, data_words, pointer_words)
  end

  sig { returns(Integer) }
  attr_reader :length

  sig { returns(Integer) }
  attr_reader :element_type
end

class CapnProto::String < CapnProto::List
  sig { params(pointer: CapnProto::Buffer).returns(T.nilable(T.attached_class)) }
  def self.from_pointer(pointer)
    super(pointer)
  end

  sig { returns(String) }
  def value = @data.read_string(0, @length - 1, Encoding::UTF_8)
end

class CapnProto::Data < CapnProto::List
  sig { params(pointer: CapnProto::Buffer).returns(T.nilable(T.attached_class)) }
  def self.from_pointer(pointer)
    super(pointer)
  end

  sig { returns(String) }
  def value = @data.read_string(0, @length - 1, Encoding::BINARY)
end
