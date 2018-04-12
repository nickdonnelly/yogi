require "./blob_provider"

class ConfigManager

  def initialize
    @config_ready = false
  end

  def load_disk_data(blob_directory : String)
    blob_fetcher = BlobProvider.new blob_directory
    @config_ready = true
  end

  def config_ready? : Bool
    @config_ready
  end

end
