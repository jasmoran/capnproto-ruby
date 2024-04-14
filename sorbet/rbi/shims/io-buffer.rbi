# typed: true

class IO
  class Buffer
    sig { params(string: String).returns(IO::Buffer) }
    sig { params(string: String, block: T.proc.params(buffer: IO::Buffer).void).void }
    def self.for(string, &block); end

    sig { returns(T.self_type) }
    def free; end

    sig { params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
    def get_string(offset = 0, length = -1, encoding = Encoding::BINARY); end

    sig { params(data_type: Symbol, offset: Integer).returns(T.any(Integer, Float)) }
    def get_value(data_type, offset); end

    sig { params(offset: Integer, length: Integer).returns(IO::Buffer) }
    def slice(offset = 0, length = -1); end
  end
end
