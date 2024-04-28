# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"

module CapnProto
  extend T::Sig

  VERSION = "0.0.1"
  WORD_SIZE = 8

  class Error < StandardError; end

  sig { params(message: ::String, block: T.proc.returns(T::Boolean)).void }
  def self.assert(message = "", &block)
    Kernel.raise Error.new("Assertion failed: #{message}") unless yield
  end
end

require_relative "capnproto/runtime"
