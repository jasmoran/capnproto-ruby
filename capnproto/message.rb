# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'
require_relative 'buffer'
require_relative 'reference'

class CapnProto::Message < CapnProto::Buffer
  extend T::Sig

  private_class_method :new

  sig { params(buffer: IO::Buffer, id: String, segments: T::Array[CapnProto::Reference]).void }
  def initialize(buffer, id, segments = [])
    super(buffer, id)
    @segments = segments
  end

  sig { params(segments: T::Array[CapnProto::Reference]).void }
  def segments=(segments)
    @segments = segments
  end

  sig { override.params(buffer: IO::Buffer, id: String).returns(T.attached_class) }
  def self.from_buffer(buffer, id)
    message = new(buffer, id)

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
    raise 'No root pointer found' if root.nil?
    root.apply_offset(0, CapnProto::WORD_SIZE)
  end

  sig { params(segment: Integer).returns(CapnProto::Buffer) }
  def get_segment(segment)
    # For testing single-word far pointers
    if segment == 1
      CapnProto::Buffer.from_string(STRUCT_NEG_EMPTY, 'SWFP-TARGET(S1)')

    # For testing double-word far pointers
    elsif segment == 10
      CapnProto::Buffer.from_string("\x00" * 16 + FAR_DOUBLE_TARGET + STRUCT_NO_POINTER, 'DWFP-TARGET(S2)') # Targeted far-pointer

    else
      raise 'Unknown segment'
    end
  end
end
