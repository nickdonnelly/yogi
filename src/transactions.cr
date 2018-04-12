require "file"

module Transactions

  # The generic type involved in adding, deleting, editing files.
  abstract class Transaction
    @committed : Bool = false

    def initialize(@config : Config)
      @committed = false
    end

    abstract def commit
    abstract def revert

    def message() : String
      "unknown transaction"
    end
  end

  class AddNewFileTransaction < Transaction

    def initialize(@filename : String, @config : Config)
      if !File.exists?(@filename)
        raise InvalidTransactionError.new
      end
    end

    def commit
      if @committed
        raise DoubleCommitError.new
      end

      @config.add @filename
      @committed = true
    rescue e
      if !e.is_a?(DoubleCommitError)
        revert
      else
        raise DoubleCommitError.new # re-raise to prevent the rescue from suppressing
      end
    end

    def revert
      @config.files.delete @filename
      @committed = false
    rescue
      raise TransactionFailedUngracefully.new
    end

    def finalize : Config
      @config
    end

    def message
      "add #{@filename}"
    end
  end



  class InvalidTransactionError < Exception
  end
  
  class DoubleCommitError < Exception
  end

  class TransactionFailedUngracefully < Exception
  end

end
