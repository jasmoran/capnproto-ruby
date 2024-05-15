# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"
require_relative "capnp/version"
require_relative "capnp/runtime"

module Capnp
  extend T::Sig

  WORD_SIZE = 8

  class Error < StandardError; end
end
