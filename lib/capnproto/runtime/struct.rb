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
    data = pointer_ref.read_bytes(0, CapnProto::WORD_SIZE)
    parts = T.cast(data.unpack("l<S<S<"), [Integer, Integer, Integer])

    # Check the type of the pointer
    pointer_type = parts[0] & 0b11
    raise CapnProto::Error.new("Pointer has type #{pointer_type}") unless pointer_type == 0

    # Shift offset to remove type bits
    parts[0] >>= 2

    parts
  end

  sig { params(pointer_ref: CapnProto::Reference).returns(T.nilable(T.attached_class)) }
  def self.from_pointer(pointer_ref)
    # Process far pointers
    pointer_ref, content_ref = pointer_ref.segment.message.dereference_pointer(pointer_ref)

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
      data_ref = pointer_ref.offset_position(data_offset)
    else
      data_ref = content_ref
    end

    # Extract pointers section
    pointers_size = pointers_words * CapnProto::WORD_SIZE
    pointers_ref = data_ref.offset_position(data_size)

    new(data_ref, data_size, pointers_ref, pointers_size)
  end

  sig { abstract.returns(Object) }
  def to_obj
  end

  private

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def read_u8(offset, default)
    (offset >= @data_size) ? default : (@data.read_u8(offset) ^ default)
  end

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def read_u16(offset, default)
    (offset >= @data_size) ? default : (@data.read_u16(offset) ^ default)
  end

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def read_u32(offset, default)
    (offset >= @data_size) ? default : (@data.read_u32(offset) ^ default)
  end

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def read_u64(offset, default)
    (offset >= @data_size) ? default : (@data.read_u64(offset) ^ default)
  end

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def read_s8(offset, default)
    (offset >= @data_size) ? default : (@data.read_s8(offset) ^ default)
  end

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def read_s16(offset, default)
    (offset >= @data_size) ? default : (@data.read_s16(offset) ^ default)
  end

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def read_s32(offset, default)
    (offset >= @data_size) ? default : (@data.read_s32(offset) ^ default)
  end

  sig { params(offset: Integer, default: Integer).returns(Integer) }
  def read_s64(offset, default)
    (offset >= @data_size) ? default : (@data.read_s64(offset) ^ default)
  end

  sig { params(offset: Integer, default: Float).returns(Float) }
  def read_f32(offset, default)
    if offset >= @data_size
      # The float is not in the data buffer
      default

    elsif default.zero?
      # The float is in the data buffer and there is no default value
      @data.read_f32(offset)

    else
      # The float is in the data buffer and there is a default value
      default_int = [default].pack("e").unpack1("L<")
      value = @data.read_u32(offset)
      [value ^ default_int].pack("L<").unpack1("e")
    end
  end

  sig { params(offset: Integer, default: Float).returns(Float) }
  def read_f64(offset, default)
    if offset >= @data_size
      # The float is not in the data buffer
      default

    elsif default.zero?
      # The float is in the data buffer and there is no default value
      @data.read_f64(offset)

    else
      # The float is in the data buffer and there is a default value
      default_int = [default].pack("E").unpack1("Q<")
      value = @data.read_u64(offset)
      [value ^ default_int].pack("Q<").unpack1("E")
    end
  end

  sig { params(ix: Integer).returns(CapnProto::Reference) }
  def read_pointer(ix)
    offset = ix * CapnProto::WORD_SIZE

    # The pointer is not in the pointer buffer
    return CapnProto::Reference::NULL_POINTER if offset >= @pointers_size

    @pointers.offset_position(offset)
  end
end
