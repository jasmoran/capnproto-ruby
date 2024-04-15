# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

module Test
  class Date < CapnProto::Struct
    sig { returns(Integer) }
    def year = read_integer(0, true, 16, 0)

    sig { returns(Integer) }
    def month = read_integer(2, false, 8, 0)

    sig { returns(Integer) }
    def day = read_integer(3, false, 8, 0)

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      year: year,
      month: month,
      day: day,
    }
  end

  class Person < CapnProto::Struct
    DEFAULT_PHONES = 8

    sig { returns(T.nilable(CapnProto::String))}
    def name = read_list(CapnProto::String, 0)

    sig { returns(T.nilable(Date)) }
    def birthdate = read_struct(Date, 2)

    sig { returns(T.nilable(CapnProto::String))}
    def email = read_list(CapnProto::String, 1)

    sig { returns(Integer) }
    def phones = read_integer(0, true, 16, DEFAULT_PHONES)

    sig { returns(T.nilable(Person)) }
    def sibling = read_struct(Person, 3)

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h = {
      name: name&.value,
      birthdate: birthdate&.to_h,
      email: email&.value,
      phones: phones,
      sibling: sibling&.to_h,
    }
  end
end
