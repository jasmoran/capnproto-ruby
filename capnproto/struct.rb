# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::Struct
  extend T::Sig

  sig do
    params(
      message: CapnProto::Message,
      data: CapnProto::Buffer::Reference,
      pointers: CapnProto::Buffer::Reference
    ).void
  end
  def initialize(message, data, pointers)
    @message = message
    @data = data
    @pointers = pointers
  end

  sig do
    params(pointer: CapnProto::Buffer::Reference)
      .returns([Integer, Integer, Integer])
  end
  def self.decode_pointer(pointer)
    # Fetch pointer data from buffer
    data = pointer.read_string(0, 8, Encoding::BINARY)
    parts = T.cast(data.unpack('l<S<S<'), [Integer, Integer, Integer])

    # Check the type of the pointer
    CapnProto::assert { parts[0] & 0b11 == 0 }

    # Shift offset to remove type bits
    parts[0] >>= 2

    parts
  end

  sig do
    params(pointer: CapnProto::Buffer::Reference)
      .returns(T.nilable([CapnProto::Buffer::Reference, CapnProto::Buffer::Reference]))
  end
  def self.get_pointer_references(pointer)
    # Decode the pointer
    offset_words, data_words, pointer_words = decode_pointer(pointer)

    # Check for empty struct
    return [CapnProto::Buffer::Reference::EMPTY, CapnProto::Buffer::Reference::EMPTY] if offset_words == -1

    # Check for NULL pointer
    return nil if offset_words.zero? && data_words.zero? && pointer_words.zero?

    # Extract data section
    data_offset = (offset_words + 1) * CapnProto::WORD_SIZE
    data_size = data_words * CapnProto::WORD_SIZE
    data_buffer = pointer.apply_offset(data_offset, data_size)

    # Extract pointer section
    pointer_offset = data_offset + data_size
    pointer_size = pointer_words * CapnProto::WORD_SIZE
    pointer_buffer = pointer.apply_offset(pointer_offset, pointer_size)

    [data_buffer, pointer_buffer]
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

  sig { params(ix: Integer).returns(T.nilable(CapnProto::Buffer::Reference)) }
  def read_pointer(ix)
    offset = ix * CapnProto::WORD_SIZE

    # The pointer is not in the pointer buffer
    return nil if offset >= @pointers.size

    @pointers.apply_offset(offset, CapnProto::WORD_SIZE)
  end

  sig { type_parameters(:S).params(klass: T::Class[T.type_parameter(:S)], ix: Integer).returns(T.nilable(T.type_parameter(:S))) }
  def read_struct(klass, ix)
    pointer = read_pointer(ix)
    return nil if pointer.nil?

    decoded = CapnProto::Struct.get_pointer_references(pointer)
    return nil if decoded.nil?

    klass.new(@message, decoded[0], decoded[1])
  end

  sig { type_parameters(:S).params(klass: T::Class[T.type_parameter(:S)], ix: Integer).returns(T.nilable(T.type_parameter(:S))) }
  def read_list(klass, ix)
    pointer = read_pointer(ix)
    return nil if pointer.nil?

    klass.new(pointer)
  end
end

class CapnProto::StructPointer
  extend T::Sig

  sig { params(segment: CapnProto::Segment, offset: Integer).void }
  def initialize(segment, offset)
    @segment = segment
    @offset = offset

    # Check the type of the pointer
    offset_part = @segment.read_integer(@offset, :s32)
    CapnProto::assert { offset_part & 0b11 == 0 }

    # Extract offset of data section
    offset_from_pointer = (offset_part >> 2) * CapnProto::WORD_SIZE
    @data_offset = T.let(@offset + offset_from_pointer + CapnProto::WORD_SIZE, Integer)

    # Extract size of data and pointer sections
    @data_size = T.let(@segment.read_integer(@offset + 4, :u16) * CapnProto::WORD_SIZE, Integer)
    @pointer_size = T.let(@segment.read_integer(@offset + 6, :u16) * CapnProto::WORD_SIZE, Integer)

    # Calculate offset of pointer section
    @pointer_offset = T.let(@data_offset + @data_size, Integer)
  end

  sig { params(offset: Integer, size: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, size, encoding) = @segment.read_string(@data_offset + offset, size, encoding)

  sig { params(offset: Integer, type: Symbol).returns(Integer) }
  def read_integer(offset, type) = @segment.read_integer(@data_offset + offset, type)

  sig { params(ix: Integer).returns(Integer) }
  def pointer_offset(ix) = @pointer_offset + ix * CapnProto::WORD_SIZE
end
