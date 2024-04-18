# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

extend T::Sig

NULL_POINTER = "\x00\x00\x00\x00\x00\x00\x00\x00"
STRUCT_NEG_EMPTY = "\xfc\xff\xff\xff\x00\x00\x00\x00"
STRUCT_NO_DATA = "\x10\x00\x00\x00\x00\x00\x03\x00"
STRUCT_NO_POINTER = "\x1c\xff\xff\xff\x02\x00\x00\x00"
LIST_EMPTY = "\x09\x00\x00\x00\x04\x00\x00\x00"
LIST_LARGE = "\x11\x00\x00\x00\xFB\xFF\xFF\xFF"
FAR_SINGLE = "\xfa\xff\xff\xff\x01\x00\x00\x00"
FAR_DOUBLE = "\x16\x00\x00\x00\x0A\x00\x00\x00"

sig { params(segment: Integer, offset: Integer).returns(String) }
def get_reference(segment, offset)
  # For testing single-word far pointers
  if segment == 1
    STRUCT_NEG_EMPTY

  # For testing double-word far pointers
  elsif offset == 16
    FAR_SINGLE # Targeted far-pointer
  elsif offset == 24
    STRUCT_NO_POINTER
  else
    raise "Invalid segment and offset combination: #{segment}, #{offset}"
  end
end

sig { params(pointer: String).returns(T.untyped) }
def decode_arbitrary_pointer(pointer)
  # Grab lower 32 bits as a signed integer and upper 32 bits as an unsigned integer
  lower, upper = T.cast(pointer.unpack('l<L<'), [Integer, Integer])

  # Check for NULL pointer
  return { type: 'NULL' } if lower.zero? && upper.zero?

  # Extract the tag and offset
  tag = lower & 0b11
  offset_words = lower >> 2

  case tag
  when 0 # Struct pointer
    data_words = upper & 0xffff
    pointer_words = upper >> 16
    { type: 'STRUCT', tag: tag, offset: offset_words, data_words: data_words, pointer_words: pointer_words }
  when 1 # List pointer
    element_size = upper & 0b111
    size = upper >> 3
    { type: 'LIST', tag: tag, offset: offset_words, element_size: element_size, size: size }
  when 2 # Far pointer
    # TODO: Check Buffer is Message type

    # Offset is signed, convert to unsigned
    offset_words = (lower & 0xffff_ffff) >> 3
    single_word = (lower & 0b100).zero?
    target = get_reference(upper, offset_words * CapnProto::WORD_SIZE)
    if single_word
      decoded_target = decode_arbitrary_pointer(target)
      decoded_target[:far_info] = { offset: offset_words, single_word: single_word, segment_id: upper }
      return decoded_target
    end

    tag = get_reference(upper, (offset_words + 1) * CapnProto::WORD_SIZE)
    decoded_tag = decode_arbitrary_pointer(tag)
    decoded_tag[:far_info1] = { offset: offset_words, single_word: single_word, segment_id: upper }
    lower, upper = T.cast(target.unpack('L<L<'), [Integer, Integer])
    decoded_tag[:far_info2] = { offset: lower >> 3, segment_id: upper }
    # decoded_tag[:offset] = lower >> 3
    # decoded_tag[:segment_id] = upper

    return decoded_tag
    #
  when 3 # Other pointer
    ''
  end
end

p decode_arbitrary_pointer(NULL_POINTER)
p decode_arbitrary_pointer(STRUCT_NEG_EMPTY)
p decode_arbitrary_pointer(STRUCT_NO_DATA)
p decode_arbitrary_pointer(STRUCT_NO_POINTER)
p decode_arbitrary_pointer(LIST_EMPTY)
p decode_arbitrary_pointer(LIST_LARGE)
p decode_arbitrary_pointer(FAR_SINGLE)
p decode_arbitrary_pointer(FAR_DOUBLE)

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
