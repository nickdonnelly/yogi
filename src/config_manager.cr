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

  def load_disk_data(blob_directory : String | Nil = nil)
    if !blob_directory.nil?
      set_blob_dir blob_directory
    end
    @current_config_name = get_current_name @config_directory 
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
    File.write("#{@config_directory}/current_config", config.name)
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

  def config_exists?(name : String) : Bool
    File.file?("#{@config_directory}/#{name}.blob")
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

  # This method will fail if the blob_fetcher has not been initialized.
  def write_current!
    @blob_fetcher.not_nil!.write_config_blob @current_config
  end

  def write!(config : Config)
    @blob_fetcher.not_nil!.write_config_blob config
  end

  def add_to_current(filepath : String)
    transaction = AddNewFileTransaction.new File.expand_path(filepath), @current_config
    transaction.commit
    set_current(transaction.finalize)
    @blob_fetcher.not_nil!.write_transaction transaction, @current_config
  end

  def remove_from_current(filepath : String)
    transaction = RemoveFileTransaction.new File.expand_path(filepath), @current_config
    transaction.commit
    set_current(transaction.finalize)
    @blob_fetcher.not_nil!.write_transaction transaction, @current_config
  end

  def update_current(filepath : String)
    transaction = EditFileTransaction.new File.expand_path(filepath), @current_config
    transaction.commit
    set_current(transaction.finalize)
    @blob_fetcher.not_nil!.write_transaction transaction, @current_config
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
  rescue
    "default"
  end
end

class ConfigFetchError < Exception
end

class ConfigActivationFailure < Exception
end
