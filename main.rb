#!/usr/bin/env ruby
# typed: strict

require 'pp'
require_relative 'test.capnp'

begin
  message = CapnProto::Message.from_io(STDIN)

  root = message.root
  exit if root.nil?

  decoded = CapnProto::Struct.get_pointer_references(root)
  exit if decoded.nil?

  person = Test::Person.new(message, decoded[0], decoded[1])
  pp person.to_h
rescue => e
  STDERR.puts("#{e.class}: #{e.message}")
  e.backtrace.to_a.reject { |line| line.include?('/gems/sorbet-runtime-') }.each { |line| STDERR.puts(line) }
end
