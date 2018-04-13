require "spec"
require "file"
require "../src/transactions"
require "../src/transactions/add_file_transaction"
require "../src/identity"
require "../src/config"

include Transactions

describe Transactions do

  it "should have an identity" do
    x = AddNewFileTransaction.new("./test_blobs/files/test_1.txt", Config.new "abc")
    x.identity.should be_a(Identity)
  end

end
