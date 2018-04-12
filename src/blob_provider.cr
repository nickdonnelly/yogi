require "io"

require "cannon"

require "./config"

class BlobProvider

  def initialize(@directory : String)
    
  end

end

struct Blob

  def self.from_config(config : Config) : self
    # Serialize the data.
    io = IO::Memory.new
    Cannon.encode io, config
    io.rewind # back to start of iterator
    bytes = Bytes.new size: io.size

    # Check right number of bytes
    result = io.read_fully(bytes)
    if result != bytes.size
      raise SerializationByteCountError.new
    end

    Blob.new(bytes)
  end

  def data : Bytes
    @bytes
  end

  def into_config : Config
    io = IO::Memory.new @bytes
    decoded = Cannon.decode io, Config
    decoded
  end

  protected def initialize(@bytes : Bytes)
  end

end

class SerializationByteCountError < Exception
end
