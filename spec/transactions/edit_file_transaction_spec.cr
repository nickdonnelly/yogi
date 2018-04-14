require "spec"
require "../../src/transactions"
require "../../src/transactions/edit_file_transaction"
require "../../src/config"

include Transactions

describe EditFileTransaction do

  config = Config.new "test_config"

  Spec.before_each do
    config = Config.new "test_config"
    config.add "./test_blobs/files/test_1.txt", "content"
  end

  it "should throw an error if the file doesn't exist" do
    expect_raises(InvalidTransactionError) do
      t = EditFileTransaction.new "some_file", config
    end
  end

  it "should throw an error if the file is not in the config" do
    expect_raises(InvalidTransactionError) do
      t = EditFileTransaction.new "./test_blobs/files/test_2.txt", config
    end
  end

  it "should have a non-default transaction message" do
    t = EditFileTransaction.new "./test_blobs/files/test_1.txt", config
    t.message.size.should be > 0
    t.message.should_not eq "unknown transaction"
  end

  it "should contain the old data" do
    t = EditFileTransaction.new "./test_blobs/files/test_1.txt", config
    t.old_content.should eq "content"
  end

  it "should change the contents" do
    t = EditFileTransaction.new "./test_blobs/files/test_1.txt", config
    t.commit
    config = t.finalize
    new_content = File.read "./test_blobs/files/test_1.txt"
    config.get("./test_blobs/files/test_1.txt").content.should eq new_content
  end

  it "should be revertible" do
    t = EditFileTransaction.new "./test_blobs/files/test_1.txt", config
    t.commit
    t.revert
    config = t.finalize
    new_content = File.read "./test_blobs/files/test_1.txt"
    config.get("./test_blobs/files/test_1.txt").content.should eq "content"
  end
end
