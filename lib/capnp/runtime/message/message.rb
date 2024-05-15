# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"

class Capnp::Message
  extend T::Sig
  extend T::Helpers
  abstract!

  sig { abstract.params(id: Integer).returns(Capnp::Segment) }
  def segment(id)
  end

  sig { returns(Capnp::Reference) }
  def root
    segment(0).to_reference
  end

  # Takes a reference to a far pointer and returns a reference to the word(s) it targets
  sig { params(far_pointer_ref: Capnp::Reference).returns(T.nilable([Capnp::Reference, T::Boolean])) }
  private def dereference_far_pointer(far_pointer_ref)
    # Grab lower and upper 32 bits of the pointer as signed integers
    pointer_data = far_pointer_ref.read_bytes(0, Capnp::WORD_SIZE)
    offset_words, segment_id = T.cast(pointer_data.unpack("L<L<"), [Integer, Integer])

    # Return if the pointer is not a far pointer
    return nil unless (offset_words & 0b11) == 2

    # Get a reference to the targeted word(s)
    target_offset = (offset_words >> 3) * Capnp::WORD_SIZE
    single_far_pointer = (offset_words & 0b100).zero?
    target_size = single_far_pointer ? 8 : 16
    segment = segment(segment_id)

    # TODO: Reconsider this check
    raise Capnp::Error.new("Invalid offset #{target_offset} for segment #{segment_id} in far pointer") if segment.size <= target_offset + target_size

    [segment.to_reference.offset_position(target_offset), single_far_pointer]
  end

  sig { params(pointer_ref: Capnp::Reference).returns([Capnp::Reference, T.nilable(Capnp::Reference)]) }
  def dereference_pointer(pointer_ref)
    target_ref, single_far_pointer = dereference_far_pointer(pointer_ref)

    # Return if the pointer is not a far pointer
    return pointer_ref, nil if target_ref.nil?

    # Check if the target is a single far pointer
    # If so, the first word is the new pointer
    return target_ref, nil if single_far_pointer

    # The first word is a far pointer to a block of content
    content_ref, single_far_pointer = dereference_far_pointer(target_ref)
    raise Capnp::Error.new("First word of double far pointer is not a far pointer") if content_ref.nil?
    raise Capnp::Error.new("Double far pointer pointing to another double far pointer") unless single_far_pointer

    # The second word is the new pointer
    target_ref = target_ref.offset_position(Capnp::WORD_SIZE)
    [target_ref, content_ref]
  end
end
