# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::Struct
  extend T::Sig

  sig { params(data: CapnProto::Reference, pointers: CapnProto::Reference).void }
  def initialize(data, pointers)
    @data = data
    @pointers = pointers
  end

  sig do
    params(pointer_ref: CapnProto::Reference)
      .returns([Integer, Integer, Integer])
  end
  def self.decode_pointer(pointer_ref)
    # Fetch pointer data from buffer
    data = pointer_ref.read_string(0, CapnProto::WORD_SIZE, Encoding::BINARY)
    parts = T.cast(data.unpack('l<S<S<'), [Integer, Integer, Integer])

    # Check the type of the pointer
    CapnProto::assert { parts[0] & 0b11 == 0 }

    # Shift offset to remove type bits
    parts[0] >>= 2

    parts
  end

  sig { params(pointer_ref: CapnProto::Reference).returns(T.nilable(T.attached_class)) }
  def self.from_pointer(pointer_ref)
    # Process far pointers
    pointer_ref, content_ref = pointer_ref.dereference_pointer

    # Decode the pointer
    offset_words, data_words, pointers_words = decode_pointer(pointer_ref)

    # Check for empty struct
    return self.new(CapnProto::Reference::EMPTY, CapnProto::Reference::EMPTY) if offset_words == -1

    # Check for NULL pointer
    return nil if offset_words.zero? && data_words.zero? && pointers_words.zero?

    # Extract data section
    data_size = data_words * CapnProto::WORD_SIZE
    if content_ref.nil?
      data_offset = (offset_words + 1) * CapnProto::WORD_SIZE
      data_ref = pointer_ref.apply_offset(data_offset, data_size)
    else
      data_ref = content_ref.apply_offset(0, data_size)
    end

    # Extract pointer section
    pointers_size = pointers_words * CapnProto::WORD_SIZE
    pointers_ref = data_ref.apply_offset(data_size, pointers_size)

    self.new(data_ref, pointers_ref)
  end

  private

  sig { params(offset: Integer, signed: T::Boolean, number_bits: Integer, default: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits, default)
    if offset >= @data.size
      # The integer is not in the data buffer
      default
    else
      # The integer is in the data buffer
      @data.read_integer(offset, signed, number_bits) ^ default
    end
  end

  sig { params(ix: Integer).returns(CapnProto::Reference) }
  def read_pointer(ix)
    offset = ix * CapnProto::WORD_SIZE

    # The pointer is not in the pointer buffer
    return CapnProto::Reference::NULL_POINTER if offset >= @pointers.size

    @pointers.apply_offset(offset, CapnProto::WORD_SIZE)
  end
end
