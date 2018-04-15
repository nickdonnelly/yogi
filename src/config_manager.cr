require "file"
require "dir"
require "io"

require "./blob_provider"
require "./transactions"
require "./transactions/*"

class ConfigManager
  include Transactions
  getter :current_config_name
  getter :current_config

  @config_directory : String = ""
  @config_ready : Bool = false
  @current_config_name : String = "default"
  @current_config : Config = Config.new "default"
  @blob_fetcher : BlobProvider | Nil = nil

  def initialize
    @config_ready = false
  end

  def set_blob_dir(blob_directory : String)
    if !Dir.exists? blob_directory
      Dir.mkdir_p blob_directory
    end
    @blob_fetcher = BlobProvider.new blob_directory
    @config_directory = blob_directory
  end

  def load_disk_data(blob_directory : String)
    set_blob_dir blob_directory
    @current_config_name = get_current_name blob_directory
    @current_config = get_by_name @current_config_name
    @config_ready = true
  rescue
    raise ConfigFetchError.new
  end

  def set_current(config : Config)
    @current_config = config
    @current_config_name = config.name
    @config_ready = true
  end

  def activate_by_name(name : String)
    config = get_by_name name
    @current_config.deactivate!
    config.activate!
    set_current config
    @config_ready = true
  rescue e
    if e.is_a?(ConfigFetchError)
      raise ConfigFetchError.new
    else
      raise ConfigActivationFailure.new
    end
  end

  def config_ready? : Bool
    @config_ready
  end

  def get_config_list : Array(String)
    list = [] of String
    Dir.entries(@config_directory).each do |entry|
      if entry.ends_with? ".blob"
        list << entry.strip ".blob"
      end
    end
    list
  end

  def add_to_current(filepath : String)
    transaction = AddNewFileTransaction.new filepath, @current_config
    transaction.commit
    @current_config = transaction.finalize
  end

  def current_contains?(filepath : String) : Bool
    @current_config.contains? filepath
  end

  def try_get_by_name(name : String) : Config | Nil
    get_by_name name
  rescue
    nil
  end

  private def get_by_name(name : String) : Config
    @blob_fetcher.not_nil!.config_from_blob name
  end

  private def get_current_name(directory : String) : String
    File.read("#{directory}/current_config").strip
  rescue IO::Error
    "default"
  end
end

class ConfigFetchError < Exception
end

class ConfigActivationFailure < Exception
end
