# typed: strong
# frozen_string_literal: true

class MessageHelper
  extend T::Sig

  STRUCT_POINTER_A = 0xA1A2A1A200000010
  STRUCT_POINTER_B = 0xB1B2B1B200000020
  STRUCT_POINTER_C = 0xC1C2C1C200000030
  STRUCT_POINTER_D = 0xD1D2D1D200000040

  sig { params(single: T::Boolean, segment_id: Integer, offset: Integer).returns(Integer) }
  def self.build_far_pointer(single, segment_id, offset)
    type = single ? 2 : 6
    type | (offset / 8) << 3 | segment_id << 32
  end

  sig { returns(CapnProto::StreamMessage) }
  def self.single_segment
    return @single_segment if @single_segment

    data = T.let([
      0,     # Number of segments (minus one)
      1,     # Size of segment 0 (in words)
      16, 32 # Segment 0 (Contains a struct pointer)
    ].pack("L<*"), String)

    message = CapnProto::StreamMessage.new(CapnProto::IOBuffer.new(IO::Buffer.for(data)))

    @single_segment ||= T.let(message, T.nilable(CapnProto::StreamMessage))

    @single_segment
  end

  sig { returns(CapnProto::StreamMessage) }
  def self.four_segment
    return @four_segment if @four_segment

    header = T.let([
      3, # Number of segments (minus one)
      7, # Size of segment 0 (in words)
      2, # Size of segment 1
      7, # Size of segment 2
      5, # Size of segment 3
      0  # Padding
    ].pack("L<*"), String)

    segments = T.let([
      # Segment 0
      build_far_pointer(true, 1, 0),   # 0+00: Single far pointer to 1+00 (STRUCT_POINTER_D)
      STRUCT_POINTER_A,                # 0+08
      build_far_pointer(true, 9, 0),   # 0+16: Single far pointer to 9+00 (Invalid segment)
      STRUCT_POINTER_B,                # 0+24
      build_far_pointer(true, 1, 32),  # 0+32: Single far pointer to 1+32 (Invalid offset)
      STRUCT_POINTER_C,                # 0+40
      build_far_pointer(false, 2, 0),  # 0+48: Double far pointer to 2+00 (Another double pointer)

      # Segment 1
      STRUCT_POINTER_D,                # 1+00
      build_far_pointer(true, 0, 8),   # 1+08: Single far pointer to 0+08 (STRUCT_POINTER_A)

      # Segment 2
      build_far_pointer(false, 0, 0),  # 2+00: Double far pointer to 0+00 (A single pointer)
      build_far_pointer(false, 8, 16), # 2+08: Double far pointer to 8+16 (Invalid segment)
      build_far_pointer(false, 1, 64), # 2+16: Double far pointer to 1+64 (Invalid offset)
      build_far_pointer(false, 1, 0),  # 2+24: Double far pointer to 1+00 (STRUCT_POINTER_D)
      build_far_pointer(false, 1, 8),  # 2+32: Double far pointer to 1+08 (Single pointer with a missing tag)
      build_far_pointer(false, 0, 16), # 2+40: Double far pointer to 0+16 (Single pointer with an invalid segment)
      build_far_pointer(false, 0, 32), # 2+48: Double far pointer to 0+32 (Single pointer with an invalid offset)

      # Segment 3
      6456, 8378, 1337, 8954, 2724 # Random data
    ].pack("Q<*"), String)

    message = CapnProto::StreamMessage.new(CapnProto::IOBuffer.new(IO::Buffer.for(header + segments)))

    @four_segment ||= T.let(message, T.nilable(CapnProto::StreamMessage))

    @four_segment
  end
end
