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

sig { params(pointer_ref: CapnProto::Reference).returns(T.untyped) }
def decode_arbitrary_pointer(pointer_ref)
  # Process far pointers
  pointer_ref, content_ref = pointer_ref.dereference_pointer

  # Grab lower 32 bits as a signed integer and upper 32 bits as an unsigned integer
  pointer_data = pointer_ref.read_string(0, CapnProto::WORD_SIZE, Encoding::BINARY)
  lower, upper = T.cast(pointer_data.unpack('l<L<'), [Integer, Integer])

  # Extract the tag
  tag = lower & 0b11

  # Check for NULL pointer
  return { type: 'NULL' } if lower.zero? && upper.zero?

  offset_words = lower >> 2

  case tag
  when 0 # Struct pointer
    data_words = upper & 0xffff
    pointers_words = upper >> 16

    # Check for empty struct
    if offset_words == -1
      return CapnProto::Struct.new(CapnProto::Reference::EMPTY, CapnProto::Reference::EMPTY)
    end

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

    return CapnProto::Struct.new(data_ref, pointers_ref)
  when 1 # List pointer
    element_type = upper & 0b111

    # Determine the length of the list
    list_size = upper >> 3
    length = list_size

    # Determine the size of the data section
    data_size = case element_type
      # Void type elements
      when 0 then 0
      # Bit type elements
      when 1 then (list_size + 7) / 8
      # Integer type elements
      when 2, 3, 4, 5 then list_size << (element_type - 2)
      # Pointer type elements
      when 6 then list_size * CapnProto::WORD_SIZE
      else (list_size + 1) * CapnProto::WORD_SIZE
    end

    # Extract data section
    if content_ref.nil?
      data_offset = (offset_words + 1) * CapnProto::WORD_SIZE
      data_ref = pointer_ref.apply_offset(data_offset, data_size)
    else
      data_ref = content_ref.apply_offset(0, data_size)
    end

    # Fetch tag for composite type elements
    data_words = 0
    pointers_words = 0
    if element_type == 7
      # Fetch tag pointer data
      data = data_ref.read_string(0, CapnProto::WORD_SIZE, Encoding::BINARY)
      length, data_words, pointers_words = T.cast(data.unpack('l<S<S<'), [Integer, Integer, Integer])

      # Check the type of the pointer
      CapnProto::assert { length & 0b11 == 0 }

      # Shift length to remove type bits
      length >>= 2

      data_ref = data_ref.apply_offset(CapnProto::WORD_SIZE, data_size - CapnProto::WORD_SIZE)
    end

    return CapnProto::List.new(data_ref, length, element_type, data_words, pointers_words)
  when 2 # Far pointer
    raise 'Nested far pointers not supported'
  when 3 # Other pointer
    return { type: 'OTHER' }
  end
end

begin
  p 'NULL_POINTER', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + NULL_POINTER, 'TST-NULL_POINTER').root)
  p 'STRUCT_NEG_EMPTY', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NEG_EMPTY, 'TST-STRUCT_NEG_EMPTY').root)
  p 'STRUCT_NO_DATA', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NO_DATA, 'TST-STRUCT_NO_DATA').root)
  p 'STRUCT_NO_POINTER', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NO_POINTER, 'TST-STRUCT_NO_POINTER').root)
  p 'LIST_EMPTY', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + LIST_EMPTY, 'TST-LIST_EMPTY').root)
  p 'LIST_LARGE', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + LIST_LARGE, 'TST-LIST_LARGE').root)
  p 'FAR_SINGLE', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + FAR_SINGLE, 'TST-FAR_SINGLE').root)
  p 'FAR_DOUBLE', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + FAR_DOUBLE, 'TST-FAR_DOUBLE').root)
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
