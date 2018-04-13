require "file"
require "io"

require "./blob_provider"
require "./transactions"

class ConfigManager
  include Transactions
  getter :current_config_name

  @config_ready : Bool = false
  @current_config_name : String = ""
  @current_config : Config = Config.new "default"

  def initialize
    @config_ready = false
  end

  def load_disk_data(blob_directory : String)
    blob_fetcher = BlobProvider.new blob_directory
    @current_config_name = get_current_name blob_directory
    @current_config = get_by_name blob_directory, @current_config_name
    @config_ready = true
  rescue
    raise ConfigFetchError.new
  end

  def config_ready? : Bool
    @config_ready
  end

  def add_to_current(filepath : String)
    transaction = AddNewFileTransaction.new filepath, @current_config
    transaction.commit
    @current_config = transaction.finalize
  end

  def current_contains?(filepath : String) : Bool
    @current_config.contains? filepath
  end

  private def get_current_name(directory : String) : String
    File.read("#{directory}/current_config").strip
  rescue IO::Error
    "default"
  end

  private def get_by_name(blob_dir : String, name : String) : Config
    provider = BlobProvider.new blob_dir
    provider.config_from_blob name
  end
end

class ConfigFetchError < Exception
end
