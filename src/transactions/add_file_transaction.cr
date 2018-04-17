require "../transactions"

module Transactions

  class AddNewFileTransaction < Transaction

    def initialize(@filename : String, @config : Config)
      if !File.exists?(@filename)
        raise InvalidTransactionError.new
      end
      super @config
    end

    # DO NOT USE. This is for deserialization
    def initialize(@committed : Bool, @config : Config | Nil, 
                   @identity : Identity, @filename : String)
    end

    def commit
      super

      contents = File.read(@filename)
      @config.not_nil!.add @filename, contents
    rescue FileAlreadyInConfig
      raise FileAlreadyInConfig.new
    rescue e
      if !e.is_a?(DoubleCommitError)
        revert
      else
        raise DoubleCommitError.new # re-raise to prevent the rescue from suppressing
      end
    end

    def revert
      if @config.not_nil!.contains? @filename
        @config.not_nil!.delete @filename
      end
      super
    rescue
      raise TransactionFailedUngracefully.new
    end

    def message
      "add #{@filename}"
    end
  end
end
