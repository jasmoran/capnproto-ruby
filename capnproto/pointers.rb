# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'
require_relative 'message'

extend T::Sig

NULL_POINTER = "\x00\x00\x00\x00\x00\x00\x00\x00"
STRUCT_NEG_EMPTY = "\xfc\xff\xff\xff\x00\x00\x00\x00"
STRUCT_NO_DATA = "\x10\x00\x00\x00\x00\x00\x03\x00"
STRUCT_NO_POINTER = "\x1c\xff\xff\xff\x02\x00\x00\x00"
LIST_EMPTY = "\x09\x00\x00\x00\x04\x00\x00\x00"
LIST_LARGE = "\x11\x00\x00\x00\xFB\xFF\xFF\xFF"
FAR_SINGLE = "\x02\x00\x00\x00\x01\x00\x00\x00"
FAR_DOUBLE = "\x16\x00\x00\x00\x0A\x00\x00\x00"
FAR_DOUBLE_TARGET = "\xfa\xff\xff\xff\x05\x00\x00\x00"

sig { params(pointer: CapnProto::Reference).returns(T.untyped) }
def decode_arbitrary_pointer(pointer)
  # Grab lower 32 bits as a signed integer and upper 32 bits as an unsigned integer
  pointer_data = pointer.read_string(0, 8, Encoding::BINARY)
  lower, upper = T.cast(pointer_data.unpack('l<L<'), [Integer, Integer])

  # Extract the tag
  tag = lower & 0b11

  # Process far pointers
  far_info2 = nil
  if tag == 2
    # Check Buffer is Message type
    buffer = pointer.buffer
    raise 'Can only follow far pointers when buffer is a CapnProto""Message' unless buffer.is_a?(CapnProto::Message)

    segment_id = upper

    # Offset is signed, convert to unsigned
    offset_words = (lower & 0xffff_ffff) >> 3
    single_word = (lower & 0b100).zero?
    far_info2 = { offset: offset_words, segment_id: segment_id }  #???

    # Read and unpack the first word of the target
    target_ref = buffer.get_segment(segment_id)
    target_offset = offset_words * CapnProto::WORD_SIZE
    target_data = target_ref.read_string(target_offset, 8, Encoding::BINARY)
    lower, upper = T.cast(target_data.unpack('l<L<'), [Integer, Integer])

    unless single_word
      # First word is a far pointer, interpret lower and upper as offset and segment ID
      far_info2 = { offset: (lower & 0xffff_ffff) >> 3, segment_id: upper }

      # Read and unpack the second word of the target
      tag_ref = buffer.get_segment(segment_id)
      tag_data = tag_ref.read_string(target_offset + CapnProto::WORD_SIZE, 8, Encoding::BINARY)
      lower, upper = T.cast(tag_data.unpack('l<L<'), [Integer, Integer])
    end

    # Extract the tag
    tag = lower & 0b11
  end

  # Check for NULL pointer
  return { type: 'NULL' } if lower.zero? && upper.zero?

  offset_words = lower >> 2

  result = {}
  case tag
  when 0 # Struct pointer
    data_words = upper & 0xffff
    pointer_words = upper >> 16

    # Check for empty struct
    if offset_words == -1
      return {
        type: 'STRUCT',
        tag: tag,
        data_buffer: CapnProto::Reference::EMPTY,
        pointer_buffer: CapnProto::Reference::EMPTY
      }
    end

    # Extract data section
    data_offset = (offset_words + 1) * CapnProto::WORD_SIZE
    data_size = data_words * CapnProto::WORD_SIZE
    data_buffer = pointer.apply_offset(data_offset, data_size)

    # Extract pointer section
    pointer_offset = data_offset + data_size
    pointer_size = pointer_words * CapnProto::WORD_SIZE
    pointer_buffer = pointer.apply_offset(pointer_offset, pointer_size)

    result = {
      type: 'STRUCT',
      tag: tag,
      data_buffer: data_buffer,
      pointer_buffer: pointer_buffer
    }
    result[:offsetx] = far_info2 if far_info2
  when 1 # List pointer
    element_type = upper & 0b111

    # Calculate offset of data section
    data_offset = (offset_words + 1) * CapnProto::WORD_SIZE

    # Determine the length of the list
    list_size = upper >> 3
    length = list_size

    # Fetch tag for composite type elements
    data_words = 0
    pointer_words = 0
    if element_type == 7
      # Fetch tag pointer data
      tag_pointer = pointer.apply_offset(data_offset, CapnProto::WORD_SIZE)
      data = pointer.read_string(0, 8, Encoding::BINARY)
      length, data_words, pointer_words = T.cast(data.unpack('l<S<S<'), [Integer, Integer, Integer])

      # Check the type of the pointer
      CapnProto::assert { length & 0b11 == 0 }

      # Shift length to remove type bits
      length >>= 2

      data_offset += CapnProto::WORD_SIZE
    end

    # Determine the size of the data section
    data_size = case element_type
      # Void type elements
      when 0 then 0
      # Bit type elements
      when 1 then (list_size + 7) / 8
      # Integer type elements
      when 2, 3, 4, 5 then list_size << (element_type - 2)
      # Pointer and Composite type elements
      else list_size * CapnProto::WORD_SIZE
    end

    data = pointer.apply_offset(data_offset, data_size)

    result = {
      type: 'LIST',
      tag: tag,
      data_buffer: data,
      length: length,
      element_type: element_type,
      struct_data_words: data_words,
      struct_pointer_words: pointer_words
    }
    result[:offsetx] = far_info2 if far_info2
  when 2 # Far pointer
    raise 'Nested far pointers not supported'
  when 3 # Other pointer
    result = { type: 'OTHER' }
  end

  result
end

begin
  p decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + NULL_POINTER).root)
  p decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NEG_EMPTY).root)
  p decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NO_DATA).root)
  p decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NO_POINTER).root)
  p decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + LIST_EMPTY).root)
  p decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + LIST_LARGE).root)
  p decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + FAR_SINGLE).root)
  p decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + FAR_DOUBLE).root)
rescue => e
  STDERR.puts("#{e.class}: #{e.message}")
  e.backtrace.to_a.reject { |line| line.include?('/gems/sorbet-runtime-') }.each { |line| STDERR.puts(line) }
end

# Required information:
# - data location (DL)
# - data size (DS)
# - pointer location (PL)
# - pointer size (PS)

# Struct can come from a:
# - regular struct pointer (RSP)
#     pointer end, data offset, data size, pointer size
#     DL = PE + DO, DS = DS,  PL = DL + DS, PS = PS

# - far pointer + regular struct pointer (FPP)
#     follow pointer => RSP
# - far pointer + tag (FPT)
#     follow pointer => far pointer + tag
#     data location (FP2), data size (tag), pointer size (tag)
#     DL = DL,      DS = DS,  PL = DL + DS, PS = PS

# - primitive list element (PRE)
#     element size, element offset
#     DL = EO,      DS = ES,  PL = NULL,    PS = 0
#     DL = EO       DS = ES,  PL = DL + DS, PS = 0
# - pointer list element (PTE)
#     element size, element offset
#     DL = NULL,    DS = 0,   PL = EO,      PS = ES
#     DL = EO,      DS = 0,   PL = DL + DS, PS = ES
# - composite list element + tag (CLT)
#     element offset + data size, pointer size
#     DL = EO,      DS = DS,  PL = EO + DS, PS = PS
#     DL = EO,      DS = DS,  PL = DL + DS, PS = PS


# class StructPointer
#   extend T::Sig
#
#
#
#   sig { params(data: Integer).void }
#   def initialize(data)
#     @data = data
#     offset_words, data_words, pointer_words
#   end
#
#
# end
