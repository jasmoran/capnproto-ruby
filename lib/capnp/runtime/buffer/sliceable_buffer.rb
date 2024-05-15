# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"

module Capnp::SliceableBuffer
  extend T::Sig
  extend T::Helpers
  interface!

  include Capnp::Buffer

  sig { abstract.params(offset: Integer, length: Integer).returns(T.self_type) }
  def slice(offset, length)
  end
end
