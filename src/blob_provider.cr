require "io"
require "file"
require "dir"
require "gzip"

require "cannon"

require "./config"

include Transactions

class BlobProvider
  # This will raise a pre-emptive `UnableToWriteFileError` if the directory doesn't exist
  # or exists but is not writable.
  def initialize(@directory : String)
    if !Dir.exists?(@directory) || !File.writable?(@directory)
      raise UnableToWriteFileError.new
    end

    if !File.file?("#{@directory}/default.blob")
      default = Config.new "default"
      write_config_blob default
    end
  end

  def remove_blob(name : String)
    if !File.file?("#{@directory}/#{name}.blob")
      raise BlobDoesntExistError.new
    end
    File.delete("#{@directory}/#{name}.blob")
  end

  def config_from_blob(blob_name : String) : Config
    blob_location = "#{@directory}/#{blob_name}.blob"

    if !File.exists?(blob_location)
      raise BlobDoesntExistError.new
    end

    blob = Blob.from_file blob_location
    blob.into_config
  rescue
    raise DeserializationDataInvalidError.new
  end

  def write_config_blob(config : Config) : Bool
    if !File.writable?(@directory)
      return false
    end

    blob_location = "#{@directory}/#{config.name}.blob"
    blob = Blob.from_config config
    blob.write blob_location

    true
  rescue IO::Error
    raise UnableToWriteFileError.new
  end

  def write_transaction(transaction : Transaction, config : Config)
    if !Dir.exists?("#{@directory}/#{config.name}")
      Dir.mkdir_p("#{@directory}/#{config.name}")
    end
    blob = Blob.from_transaction transaction
    ident = config.latest_commit.not_nil![0].shortened
    location = "#{@directory}/#{config.name}/#{ident}.blob"
    blob.write location
  end

end

struct Blob

  def self.from_config(config : Config) : self
    # Serialize the data.
    io = IO::Memory.new
    Cannon.encode io, config
    io.rewind # back to start of iterator

    # Check right number of bytes
    bytes = Bytes.new size: io.size
    result = io.read_fully(bytes)
    if result != bytes.size
      raise BlobByteCountError.new
    end

    Blob.new(bytes)
  end

  def self.from_transaction(transaction : Transaction) : self
    io = IO::Memory.new
    if transaction.is_a? AddNewFileTransaction
      Cannon.encode io, transaction.without_config.as(AddNewFileTransaction)
    elsif transaction.is_a? RemoveFileTransaction
      Cannon.encode io, transaction.without_config.as(RemoveFileTransaction)
    elsif transaction.is_a? EditFileTransaction
      Cannon.encode io, transaction.without_config.as(EditFileTransaction)
    else
      raise UnknownTransactionType.new
    end

    io.rewind
    bytes = Bytes.new size: io.size
    result = io.read_fully(bytes)
    if result != bytes.size
      raise BlobByteCountError.new
    end

    Blob.new(bytes)
  end

  # It is assumed you check for the existence of the file before calling this
  # function
  def self.from_file(filename : String) : self
    file = File.open(filename)
    bytes = Bytes.new(size: file.size)
    num = file.read(bytes)

    if num != bytes.size 
      raise BlobByteCountError.new
    end

    Blob.new bytes
  rescue IO::Error
    raise UnableToReadFileError.new
  end

  def data : Bytes
    @bytes
  end

  # Convert the blob into a Config object
  def into_config : Config
    io = IO::Memory.new @bytes
    decoded = Cannon.decode io, Config
    decoded
  rescue
    raise DeserializationDataInvalidError.new
  end

  def write(blob_location : String)
    File.write blob_location, @bytes
  end

  protected def initialize(@bytes : Bytes)
  end
end

class BlobByteCountError < Exception
end

class DeserializationDataInvalidError < Exception
end

class UnableToReadFileError < Exception
end

class UnableToWriteFileError < Exception
end

class UnknownTransactionType < Exception
end

class BlobDoesntExistError < Exception
end
