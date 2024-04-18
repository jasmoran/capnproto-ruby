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

begin
  # p 'NULL_POINTER', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + NULL_POINTER, 'TST-NULL_POINTER').root)
  # p 'STRUCT_NEG_EMPTY', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NEG_EMPTY, 'TST-STRUCT_NEG_EMPTY').root)
  # p 'STRUCT_NO_DATA', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NO_DATA, 'TST-STRUCT_NO_DATA').root)
  # p 'STRUCT_NO_POINTER', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + STRUCT_NO_POINTER, 'TST-STRUCT_NO_POINTER').root)
  # p 'LIST_EMPTY', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + LIST_EMPTY, 'TST-LIST_EMPTY').root)
  # p 'LIST_LARGE', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + LIST_LARGE, 'TST-LIST_LARGE').root)
  # p 'FAR_SINGLE', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + FAR_SINGLE, 'TST-FAR_SINGLE').root)
  # p 'FAR_DOUBLE', decode_arbitrary_pointer(CapnProto::Message.from_string("\x00\x00\x00\x00\x01\x00\x00\x00" + FAR_DOUBLE, 'TST-FAR_DOUBLE').root)
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
