require "spec"
require "../src/config"

describe Config do
  context "names" do
    it "has a name" do
      conf = Config.new("somename")
      conf.name.should be("somename")
    end

    it "refuses names with invalid characters" do
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
  end

  context "files" do
    it "has a list of current file paths" do
      conf = Config.new("first_name")
      conf.files.size.should eq 0
    end

    it "should let files be added" do
      conf = Config.new("first_name")
      conf.add "filename"
      conf.files.size.should eq 1
    end

  end
end
