# typed: strict

require "sorbet-runtime"
require_relative "buffer"

class CapnProto::Message < CapnProto::Buffer
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

    # Create segments
    message.segments = (1..number_of_segments).map do |ix|
      # Get segment size in bytes
      segment_size = message.read_integer(ix * 4, false, 32) * CapnProto::WORD_SIZE

      # Create segment
      segment = CapnProto::Reference.new(message, offset, segment_size)

      offset += segment_size
      segment
    end

    message
  end

  sig { returns(CapnProto::Reference) }
  def root
    root = @segments.first
    raise "No root pointer found" if root.nil?
    root.apply_offset(0, CapnProto::WORD_SIZE)
  end

  # Takes a reference to a far pointer and returns a reference to the word(s) it targets
  sig { params(far_pointer_ref: CapnProto::Reference).returns(T.nilable(CapnProto::Reference)) }
  private def dereference_far_pointer(far_pointer_ref)
    # Grab lower and upper 32 bits of the pointer as signed integers
    pointer_data = far_pointer_ref.read_string(0, CapnProto::WORD_SIZE, Encoding::BINARY)
    offset_words, segment_id = T.cast(pointer_data.unpack("L<L<"), [Integer, Integer])

    # Return if the pointer is not a far pointer
    return nil unless (offset_words & 0b11) == 2

    # Get a reference to the targeted word(s)
    target_offset = (offset_words >> 3) * CapnProto::WORD_SIZE
    target_size = (offset_words & 0b100).zero? ? 8 : 16
    target_ref = @segments[segment_id]&.apply_offset(target_offset, target_size)

    raise "Unknown segment ID #{segment_id} in far pointer" if target_ref.nil?

    target_ref
  end

  sig { override.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
    target_ref = dereference_far_pointer(pointer_ref)

    # Return if the pointer is not a far pointer
    return pointer_ref, nil if target_ref.nil?

    # Check if the target is a single-word far pointer
    if target_ref.size == 8
      # The first word is the new pointer
      [target_ref, nil]
    else
      # The first word is a far pointer to a block of content
      content_ref = dereference_far_pointer(target_ref)
      raise "First word of two-word far pointer is not a far pointer" if content_ref.nil?

      # The second word is the new pointer
      target_ref = target_ref.apply_offset(CapnProto::WORD_SIZE, CapnProto::WORD_SIZE)
      [target_ref, content_ref]
    end
  end
end
