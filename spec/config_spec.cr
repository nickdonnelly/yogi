require "spec"
require "../src/config"
require "../src/transactions/add_file_transaction"

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
      conf.add "filename", "test_content"
      conf.files.size.should eq 1
      conf.files[0].content.should eq "test_content"
    end

    it "should let files be deleted" do
      conf = Config.new "some_name"
      conf.add "filename", ""
      conf.delete "filename"
      conf.files.size.should eq 0
    end

    it "should let files be plucked" do
      conf = Config.new "some_name"
      conf.add "filename", ""
      f = conf.pluck_file "filename"
      f.should_not be_nil
      conf.files.size.should eq 0
    end

    it "should be able to detect changes on the disk" do
      conf = Config.new "some_name"
      conf.add "./test_blobs/files/test_1.txt", "abcd" # this isn't in that file
      conf.has_changes?.should be_true
    end
  end

  context "transactions" do
    it "contains a list of commits" do
      conf = Config.new "some_name"
      #conf.commits.should_not be_nil
    end

    it "lets commits be added stackwise" do
      conf = Config.new "some_name"
      t1 = Transactions::AddNewFileTransaction.new "./test_blobs/files/test_1.txt", conf
      t1.commit
      conf = t1.finalize

      t2 = Transactions::AddNewFileTransaction.new "./test_blobs/files/test_2.txt", conf
      t2.commit
      conf = t2.finalize

      conf.latest_commit[0].should eq t2.identity
    end
  end
end
