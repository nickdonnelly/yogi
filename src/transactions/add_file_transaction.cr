require "../transactions"

module Transactions

  class AddNewFileTransaction < Transaction

    def initialize(@filename : String, @config : Config)
      if !File.exists?(@filename)
        raise InvalidTransactionError.new
      end
      super @config
    end

    def commit
      super

      contents = File.read(@filename)
      @config.add @filename, contents
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
end
