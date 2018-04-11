require "spec"
require "../src/config"

describe Config do
  context "names" do
    it "has a name" do
      conf = Config.new("somename")
      conf.name.should be("somename")
    end

    it "refuses path names with invalid characters" do
      expect_raises(InvalidConfigurationName) do
        conf = Config.new("name wit\"* bad characters?")
      end
    end
    
    it "refuses multi-word names" do
      expect_raises(InvalidConfigurationName) do
        conf = Config.new("two words")
      end
    end

    it "allows a name to be changed" do
      conf = Config.new("first_name")
      conf.change_name("second_name")
      conf.name.should be "second_name"
    end

    it "can be activated" do
      conf = Config.new("config_name")
      conf.activate

      conf.active?.should be_true
    end

    it "can be deactivated" do
      conf = Config.new "config_name"
      conf.activate
      conf.deactivate

      conf.active?.should be_false
    end

  end
end
