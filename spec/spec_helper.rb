# typed: ignore
# frozen_string_literal: true

require "simplecov"
require "simplecov-lcov"

# Clear out old coverage results
coverage_dir = File.join(__dir__, "..", "coverage")
FileUtils.rm_rf(coverage_dir) if File.exist?(coverage_dir)

# Collect test coverage information
SimpleCov.start do
  # Output LCOV format for CI
  if ENV["CI"]
    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = "coverage/lcov.info"
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  # Enable branch coverage
  enable_coverage :branch

  # Filter out spec files and generated capnp.rb files
  add_filter %r{^/spec/}
  add_filter ".capnp.rb"
end

require "capnp"
require "capnp/generator"
require "minitest"
require "minitest/spec"
require "minitest/mock"

# Enable checking for sigs marked checked tests
T::Configuration.enable_checking_for_sigs_marked_checked_tests

# Alias describe to context for clarity in specs
module Minitest
  class Spec
    module DSL
      alias_method :context, :describe
    end
  end
end

# Run tests
Minitest.autorun
