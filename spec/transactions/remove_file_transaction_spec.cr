require "spec"
require "../../src/transactions"
require "../../src/transactions/remove_file_transaction"
require "../../src/config"

include Transactions

describe RemoveFileTransaction do

  config = Config.new "test_config"

  Spec.before_each do
    config = Config.new "test_config"
    config.add "test_file", "test_contents"
  end

  it "removes files" do
    transaction = RemoveFileTransaction.new "test_file", config
    transaction.commit
    transaction.finalize
    config.files.size.should eq 0
  end

  it "can be reverted" do
    transaction = RemoveFileTransaction.new "test_file", config
    transaction.commit
    transaction.revert
    transaction.finalize
    config.files.size.should eq 1
  end

end
