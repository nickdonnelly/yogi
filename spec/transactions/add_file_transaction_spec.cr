require "spec"
require "../../src/transactions"
require "../../src/transactions/add_file_transaction"
require "../../src/config"

include Transactions

describe AddNewFileTransaction do

  config = Config.new "test_config"

  Spec.before_each do
    config = Config.new "test_config"
  end

  it "should throw an error if the file doesn't exist" do
    expect_raises(InvalidTransactionError) do
      t = AddNewFileTransaction.new "some_file", config
    end
  end

  it "should have a non-default transaction message" do
    t = AddNewFileTransaction.new "./test_blobs/files/test_1.txt", config
    t.message.size.should be > 0
    t.message.should_not eq "unknown transaction"
  end

  it "should add a new file to the config" do
    contents = File.read "./test_blobs/files/test_1.txt"
    t = AddNewFileTransaction.new "./test_blobs/files/test_1.txt", config
    t.commit
    new_config = t.finalize
    new_config.files.size.should eq 1
    new_config.files[0].content.should eq contents
  end

  it "shouldn't allow double commits" do
    expect_raises(DoubleCommitError) do
      t = AddNewFileTransaction.new "./test_blobs/files/test_1.txt", config
      t.commit
      t.commit
    end
  end

  it "should be revertible" do
    t = AddNewFileTransaction.new "./test_blobs/files/test_1.txt", config
    t.commit
    t.revert
    new_config = t.finalize
    new_config.files.size.should eq 0
  end
end
