require "./identity"

require "file"

module Transactions

  # The generic type involved in adding, deleting, editing files.
  abstract class Transaction
    getter :identity
    @committed : Bool = false

    def initialize(@config : Config)
      @committed = false
      @identity = Identity.new
    end

    def commit
      if @committed
        raise DoubleCommitError.new
      end
      @committed = true
    end

    def revert
      @committed = false
    end

    def finalize : Config
      @config
    end

    def message() : String
      "unknown transaction"
    end
  end

  class InvalidTransactionError < Exception
  end
  
  class DoubleCommitError < Exception
  end

  class TransactionFailedUngracefully < Exception
  end

end
