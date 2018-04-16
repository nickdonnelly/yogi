require "./identity"

require "file"

require "cannon"

module Transactions

  # The generic type involved in adding, deleting, editing files.
  abstract class Transaction

    include Cannon::Auto

    getter :identity

    def_clone

    @config : Config | Nil
    @committed : Bool = false

    def initialize(config : Config)
      @config = config
      @committed = false
      @identity = Identity.new
    end

    # DO NOT USE. This is for deserialization
    def initialize(@committed : Bool, @config : Config | Nil, @identity : Identity)
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
      @config.not_nil!.add_transaction self
      @config.not_nil!
    end

    # Returns a *cloned* version of the transacation without the config.
    def without_config : self
      new = self.clone
      new.remove_config
      new
    end

    def remove_config
      @config = nil
    end

    def set_config(cfg : Config)
      @config = cfg
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
