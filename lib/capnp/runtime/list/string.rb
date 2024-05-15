# typed: strict

require "sorbet-runtime"
require_relative "list"

module Capnp::String
  include Capnp::List
  extend T::Sig
  extend T::Generic
  extend T::Helpers

  abstract!

  Elem = type_member { {fixed: String} }

  sig { abstract.returns(String) }
  def to_s
  end

  sig { override.returns(Object) }
  def to_obj
    to_s
  end
end
