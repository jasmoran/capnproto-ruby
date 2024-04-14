#!/usr/bin/env ruby
# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

module Test
  class Date < CapnProto::StructPointer
    sig { returns(Integer) }
    def year = read_integer(0, :u16)

    sig { returns(Integer) }
    def month = read_integer(2, :U8)

    sig { returns(Integer) }
    def day = read_integer(3, :U8)

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      year: year,
      month: month,
      day: day,
    }
  end

  class Person < CapnProto::StructPointer
    DEFAULT_PHONES = 8

    sig { returns(String)}
    def name = CapnProto::StringPointer.new(@segment, pointer_offset(0)).value

    sig { returns(Test::Date) }
    def birthdate = Date.new(@segment, pointer_offset(2))

    sig { returns(String) }
    def email = CapnProto::StringPointer.new(@segment, pointer_offset(1)).value

    sig { returns(Integer) }
    def phones = read_integer(0, :s16) ^ DEFAULT_PHONES

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      name: name,
      birthdate: birthdate.to_h,
      email: email,
      phones: phones,
    }
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'pp'
  buffer = IO::Buffer.for(STDIN.read)
  message = CapnProto::Message.new(buffer)
  root = message.root
  exit if root.nil?
  sp = Test::Person.new(root, 0)
  pp sp.to_h
  buffer.free
end
