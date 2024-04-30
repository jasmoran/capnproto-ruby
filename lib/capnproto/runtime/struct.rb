# typed: strict

require "sorbet-runtime"

class CapnProto::Struct
  extend T::Sig
  extend T::Helpers

  abstract!

  sig { params(data: CapnProto::Reference, data_size: Integer, pointers: CapnProto::Reference, pointers_size: Integer).void }
  def initialize(data, data_size, pointers, pointers_size)
    @data = data
    @data_size = data_size
    @pointers = pointers
    @pointers_size = pointers_size
  end

  sig do
    params(pointer_ref: CapnProto::Reference)
      .returns([Integer, Integer, Integer])
  end
  def self.decode_pointer(pointer_ref)
    # Fetch pointer data from buffer
    data = pointer_ref.read_string(0, CapnProto::WORD_SIZE, Encoding::BINARY)
    parts = T.cast(data.unpack("l<S<S<"), [Integer, Integer, Integer])

    # Check the type of the pointer
    CapnProto.assert { parts[0] & 0b11 == 0 }

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
    return new(CapnProto::Reference::EMPTY, 0, CapnProto::Reference::EMPTY, 0) if offset_words == -1

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

    new(data_ref, data_size, pointers_ref, pointers_size)
  end

  sig { abstract.returns(Object) }
  def to_obj
  end

  private

  sig { params(offset: Integer, signed: T::Boolean, number_bits: Integer, default: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits, default)
    if offset >= @data_size
      # The integer is not in the data buffer
      default
    else
      # The integer is in the data buffer
      @data.read_integer(offset, signed, number_bits) ^ default
    end
  end

  sig { params(offset: Integer, number_bits: Integer, default: Float).returns(Float) }
  def read_float(offset, number_bits, default)
    if offset >= @data_size
      # The float is not in the data buffer
      default

    elsif default.zero?
      # The float is in the data buffer and there is no default value
      @data.read_float(offset, number_bits)

    else
      # The float is in the data buffer and there is a default value
      float_type = (number_bits == 32) ? "e" : "E"
      int_type = (number_bits == 32) ? "L<" : "Q<"
      default_int = [default].pack(float_type).unpack1(int_type)
      value = @data.read_integer(offset, false, number_bits)
      [value ^ default_int].pack(int_type).unpack1(float_type)
    end
  end

  sig { params(ix: Integer).returns(CapnProto::Reference) }
  def read_pointer(ix)
    offset = ix * CapnProto::WORD_SIZE

    # The pointer is not in the pointer buffer
    return CapnProto::Reference::NULL_POINTER if offset >= @pointers_size

    @pointers.apply_offset(offset, CapnProto::WORD_SIZE)
  end
end
