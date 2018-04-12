require "file"
require "io"

require "./blob_provider"

class ConfigManager
  getter :current_config_name

  @config_ready : Bool = false
  @current_config_name : String = ""

  def initialize
    @config_ready = false
  end

  def load_disk_data(blob_directory : String)
    blob_fetcher = BlobProvider.new blob_directory
    @current_config_name = get_current_name blob_directory
    @config_ready = true
  end

  def config_ready? : Bool
    @config_ready
  end


  private def get_current_name(directory : String) : String
    File.read("#{directory}/current_config").strip
  rescue IO::Error
    "default"
  end
end
