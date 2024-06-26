# typed: strict

require "sorbet-runtime"
require_relative "../list"

class Capnp::BufferList
  include Capnp::List
  extend T::Sig
  extend T::Generic
  extend T::Helpers

  abstract!

  Elem = type_member(:out)

  private_class_method :new

  sig do
    params(
      data: Capnp::Reference,
      length: Integer,
      element_type: Integer,
      element_size: Integer,
      data_words: Integer,
      pointer_words: Integer
    ).void
  end
  def initialize(data, length, element_type, element_size, data_words, pointer_words)
    @data = data
    @length = length
    @element_type = element_type
    @element_size = element_size
    @data_words = data_words
    @pointer_words = pointer_words
  end

  sig { params(pointer_ref: Capnp::Reference).returns(T.nilable(T.attached_class)) }
  def self.from_pointer(pointer_ref)
    # Process far pointers
    pointer_ref, content_ref = pointer_ref.segment.message.dereference_pointer(pointer_ref)

    # Grab lower 32 bits as offset and upper 32 bits as size
    pointer_data = pointer_ref.read_bytes(0, Capnp::WORD_SIZE)
    offset_part, size_part = T.cast(pointer_data.unpack("l<L<"), [Integer, Integer])

    # Check for NULL pointer
    return nil if offset_part.zero? && size_part.zero?

    # Check this is a list pointer
    pointer_type = offset_part & 0b11
    raise Capnp::Error.new("List pointer has type #{pointer_type}") unless pointer_type == 1

    # Determine the length of the list
    length = size_part >> 3

    # Determine the size of the data section and individual elements
    element_type = size_part & 0b111
    element_size = case element_type
    # Void type elements
    when 0 then 0
    # Bit type elements
    when 1 then 1
    # Integer type elements
    when 2, 3, 4, 5 then 1 << (element_type - 2)
    # Pointer type elements
    when 6 then Capnp::WORD_SIZE
    # Composite type elements
    else
      0 # (Set below)
    end

    # Extract data section
    if content_ref.nil?
      data_offset = ((offset_part >> 2) + 1) * Capnp::WORD_SIZE
      data_ref = pointer_ref.offset_position(data_offset)
    else
      data_ref = content_ref
    end

    # Fetch tag for composite type elements
    data_words = 0
    pointers_words = 0
    if element_type == 7
      # Decode tag as a struct pointer
      length, data_words, pointers_words = Capnp::Struct.decode_pointer(data_ref)
      data_ref = data_ref.offset_position(Capnp::WORD_SIZE)

      # Calculate element size
      element_size = (data_words + pointers_words) * Capnp::WORD_SIZE
    end

    new(data_ref, length, element_type, element_size, data_words, pointers_words)
  end

  sig { override.returns(Integer) }
  attr_reader :length

  sig { returns(Integer) }
  attr_reader :element_type
end
