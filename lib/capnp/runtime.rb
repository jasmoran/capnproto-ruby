# typed: strict

Dir.glob(File.join(__dir__, "runtime", "**", "*.rb")) { |file| require file }
