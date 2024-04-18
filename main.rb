#!/usr/bin/env ruby
# typed: strict

require 'pp'
require_relative 'test.capnp'

begin
  message = CapnProto::Message.from_io(STDIN, 'STDIN')
  person = Test::Person.from_pointer(message.root)
  pp person.to_h
rescue => e
  STDERR.puts("#{e.class}: #{e.message}")
  e.backtrace.to_a.reject { |line| line.include?('/gems/sorbet-runtime-') }.each { |line| STDERR.puts(line) }
end
