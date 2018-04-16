require "spec"
require "../src/config_manager"

describe ConfigManager do
  manager : ConfigManager = ConfigManager.new
  provider : BlobProvider = BlobProvider.new "./test_blobs"
  config : Config = Config.new "default"
  config2 : Config = Config.new "default"

  Spec.before_each do
    manager = ConfigManager.new
    manager.set_blob_dir "./test_blobs"
    config = Config.new "test_config"
    config.add "./test_blobs/files/test_1.txt", File.read("./test_blobs/files/test_1.txt")
    config.add "./test_blobs/files/test_2.txt", File.read("./test_blobs/files/test_2.txt")
    config.add "./test_blobs/files/test_3.txt", File.read("./test_blobs/files/test_3.txt")

    config2 = Config.new "test_config2"
    config2.add "./test_blobs/files/test_11.txt", "some text"
    config2.add "./test_blobs/files/test_22.txt", "some text 2"
    config2.add "./test_blobs/files/test_33.txt", "some text 3"

    provider.write_config_blob config
    provider.write_config_blob config2
    manager.activate_by_name "test_config"
  end

  Spec.after_each do
    manager.activate_by_name "test_config"
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

  it "contains the right files after deserialization" do
    manager.activate_by_name "test_config2"
    manager.current_contains?("./test_blobs/files/test_11.txt").should be_true
    manager.current_contains?("./test_blobs/files/test_22.txt").should be_true
    manager.current_contains?("./test_blobs/files/test_33.txt").should be_true
  end

  context "#load_disk_data" do
    it "should load the current config name" do
      manager.load_disk_data "./test_blobs"
      manager.current_config_name.should eq "test_config"
    end
  end

  context "#activate_by_name" do
    it "sets the current config" do
      manager.set_current config
      manager.current_config.should eq config
      manager.config_ready?.should be_true
    end

    it "reflects the new config on disk" do
      manager.activate_by_name "test_config2"
      File.exists?("./test_blobs/files/test_1.txt").should be_false
      File.exists?("./test_blobs/files/test_11.txt").should be_true
    end

    it "makes paths that don't exist" do
      config = Config.new "third_config"
      config.add "./test_blobs/files/nested/test_1.txt", File.read("./test_blobs/files/test_1.txt")
      provider.write_config_blob config

      manager.activate_by_name "third_config"
      Dir.exists?("./test_blobs/files/nested").should be_true
    end

    it "errors on activating of non-existant config" do
      expect_raises(ConfigActivationFailure) do
        manager.activate_by_name "doesnt_exist"
      end
    end
  end

end
