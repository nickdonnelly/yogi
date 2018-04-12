require "spec"
require "../src/config_manager"

describe ConfigManager do
  manager : ConfigManager = ConfigManager.new
  provider : BlobProvider = BlobProvider.new "./test_blobs"

  Spec.before_each do
    manager = ConfigManager.new
    config = Config.new "test_config"
    provider.write_config_blob config
  end

  it "initializes a config" do
    manager.load_disk_data "./test_blobs"
    manager.config_ready?.should be_true
  end

  it "allows files to be added to the current config" do
    manager.load_disk_data "./test_blobs"
    manager.add_to_current "./test_blobs/files/test_1.txt"

    manager.current_contains?("./test_blobs/files/test_1.txt").should be_true
  end

  context "#load_disk_data" do
    it "should load the current config name" do
      manager.load_disk_data "./test_blobs"
      manager.current_config_name.should eq "test_config"
    end
  end


end
