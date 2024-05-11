# typed: strict

require "sorbet-runtime"
require_relative "buffer"

class CapnProto::Message < CapnProto::IOBuffer
  extend T::Sig

  private_class_method :new

  sig { params(buffer: IO::Buffer, segments: T::Array[CapnProto::Reference]).void }
  def initialize(buffer, segments = [])
    super(buffer)
    @segments = segments
  end

  sig { params(segments: T::Array[CapnProto::Reference]).void }
  attr_writer :segments

  sig { override.params(buffer: IO::Buffer).returns(T.attached_class) }
  def self.from_buffer(buffer)
    message = new(buffer)

    # Extract number of segments
    number_of_segments = message.read_integer(0, false, 32) + 1

    # Calculate size of the message header
    offset = 4 * (number_of_segments + 1)
    offset += 4 if number_of_segments.even?

    # Check that the buffer is large enough for all segment sizes
    raise CapnProto::Error.new("Not enough segment sizes provided") if buffer.size <= offset

    # Create segments
    message.segments = (1..number_of_segments).map do |ix|
      # Get segment size in bytes
      segment_size = message.read_integer(ix * 4, false, 32) * CapnProto::WORD_SIZE

      # Check that the buffer is large enough for the segment
      raise CapnProto::Error.new("Buffer smaller than provided segment sizes") if buffer.size < offset + segment_size

      # Create segment
      segment = CapnProto::Reference.new(message, offset, offset...(offset + segment_size))

      offset += segment_size
      segment
    end

    message
  end

  sig { returns(T::Array[CapnProto::Reference]) }
  attr_reader :segments

  sig { returns(CapnProto::Reference) }
  def root
    T.must(@segments.first)
  end

  # Takes a reference to a far pointer and returns a reference to the word(s) it targets
  sig { params(far_pointer_ref: CapnProto::Reference).returns(T.nilable([CapnProto::Reference, T::Boolean])) }
  private def dereference_far_pointer(far_pointer_ref)
    # Grab lower and upper 32 bits of the pointer as signed integers
    pointer_data = far_pointer_ref.read_string(0, CapnProto::WORD_SIZE, Encoding::BINARY)
    offset_words, segment_id = T.cast(pointer_data.unpack("L<L<"), [Integer, Integer])

    # Return if the pointer is not a far pointer
    return nil unless (offset_words & 0b11) == 2

    # Get a reference to the targeted word(s)
    target_offset = (offset_words >> 3) * CapnProto::WORD_SIZE
    single_far_pointer = (offset_words & 0b100).zero?
    target_size = single_far_pointer ? 8 : 16
    segment = @segments[segment_id]
    raise CapnProto::Error.new("Unknown segment ID #{segment_id} in far pointer") if segment.nil?

    # TODO: Reconsider this check
    buffer_offset = segment.bounds.begin + target_offset + target_size - 1
    raise CapnProto::Error.new("Invalid offset #{target_offset} for segment #{segment_id} in far pointer") unless segment.bounds.cover?(buffer_offset)

    [segment.offset_position(target_offset), single_far_pointer]
  end

  sig { override.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
    target_ref, single_far_pointer = dereference_far_pointer(pointer_ref)

    # Return if the pointer is not a far pointer
    return pointer_ref, nil if target_ref.nil?

    # Check if the target is a single far pointer
    # If so, the first word is the new pointer
    return target_ref, nil if single_far_pointer

    # The first word is a far pointer to a block of content
    content_ref, single_far_pointer = dereference_far_pointer(target_ref)
    raise CapnProto::Error.new("First word of double far pointer is not a far pointer") if content_ref.nil?
    raise CapnProto::Error.new("Double far pointer pointing to another double far pointer") unless single_far_pointer

    # The second word is the new pointer
    target_ref = target_ref.offset_position(CapnProto::WORD_SIZE)
    [target_ref, content_ref]
  end
end
