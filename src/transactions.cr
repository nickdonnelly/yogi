require "file"

module Transactions

  # The generic type involved in adding, deleting, editing files.
  abstract class Transaction
    @committed : Bool = false

    def initialize(@config : Config)
      @committed = false
    end

    def commit
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

      contents = File.read(@filename)
      @config.add @filename, contents
      super
    rescue e
      if !e.is_a?(DoubleCommitError)
        revert
      else
        raise DoubleCommitError.new # re-raise to prevent the rescue from suppressing
      end
    end

    def revert
      @config.delete @filename
      super
    rescue
      raise TransactionFailedUngracefully.new
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
