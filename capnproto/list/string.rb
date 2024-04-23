# typed: strict

require 'sorbet-runtime'
require_relative 'list'

module CapnProto::String
  include CapnProto::List
  extend T::Sig
  extend T::Generic
  extend T::Helpers

  interface!

  Elem = type_member {{fixed: String}}

  sig { abstract.returns(String) }
  def to_s; end
end
