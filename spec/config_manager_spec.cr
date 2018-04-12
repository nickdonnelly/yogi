require "spec"
require "../src/config_manager"

describe ConfigManager do
  manager : ConfigManager = ConfigManager.new

  Spec.before_each do
    manager = ConfigManager.new
  end

  it "initializes a config" do
    manager.load_disk_data "./test_blobs"
    manager.config_ready?.should be_true
  end

  context "#load_disk_data" do
    it "should load the current config name" do
      manager.load_disk_data "./test_blobs"
      manager.current_config_name.should eq "test_config"
    end
  end


end
