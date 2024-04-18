# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::List
  extend T::Sig

  private

  sig do
    params(
      data: CapnProto::Reference,
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

  sig { params(pointer_ref: CapnProto::Reference).returns(T.nilable(T.attached_class)) }
  def self.from_pointer(pointer_ref)
    # Process far pointers
    pointer_ref, content_ref = pointer_ref.dereference_pointer

    # Grab lower 32 bits as offset and upper 32 bits as size
    pointer_data = pointer_ref.read_string(0, CapnProto::WORD_SIZE, Encoding::BINARY)
    offset_part, size_part = T.cast(pointer_data.unpack('l<L<'), [Integer, Integer])

    # Check for NULL pointer
    return nil if offset_part.zero? && size_part.zero?

    # Check this is a list pointer
    pointer_type = offset_part & 0b11
    CapnProto::assert("List pointer has type #{pointer_type}") { pointer_type == 1 }

    # Determine the length of the list
    length = size_part >> 3

    # Determine the size of the data section
    element_type = size_part & 0b111
    data_size = case element_type
      # Void type elements
      when 0 then 0
      # Bit type elements
      when 1 then (length + 7) / 8
      # Integer type elements
      when 2, 3, 4, 5 then length << (element_type - 2)
      # Pointer type elements
      when 6 then length * CapnProto::WORD_SIZE
      # Composite type elements
      else (length + 1) * CapnProto::WORD_SIZE
    end

    # Extract data section
    if content_ref.nil?
      data_offset = ((offset_part >> 2) + 1) * CapnProto::WORD_SIZE
      data_ref = pointer_ref.apply_offset(data_offset, data_size)
    else
      data_ref = content_ref.apply_offset(0, data_size)
    end

    # Fetch tag for composite type elements
    data_words = 0
    pointers_words = 0
    if element_type == 7
      # Decode tag as a struct pointer
      length, data_words, pointers_words = CapnProto::Struct.decode_pointer(data_ref)
      data_ref = data_ref.apply_offset(CapnProto::WORD_SIZE, data_size - CapnProto::WORD_SIZE)
    end

    self.new(data_ref, length, element_type, data_words, pointers_words)
  end

  sig { returns(Integer) }
  attr_reader :length

  sig { returns(Integer) }
  attr_reader :element_type
end

class CapnProto::String < CapnProto::List
  sig { returns(String) }
  def value = @data.read_string(0, @length - 1, Encoding::UTF_8)
end

class CapnProto::Data < CapnProto::List
  sig { returns(String) }
  def value = @data.read_string(0, @length - 1, Encoding::BINARY)
end
