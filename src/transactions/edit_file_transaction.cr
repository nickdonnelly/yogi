require "../transactions"

module Transactions

  class EditFileTransaction < Transaction
    getter :old_content

    @old_content : String = ""

    def initialize(@filename : String, @config : Config)
      if !File.exists?(@filename) || !@config.contains?(@filename)
        raise InvalidTransactionError.new
      end
      @old_content = @config.get(@filename).content
      super @config
    end

    def commit
      super
      file = @config.pluck_file(@filename)
      file.content = File.read(@filename)
      @config.add file
    rescue e
      if !e.is_a?(DoubleCommitError)
        revert
      else
        raise DoubleCommitError.new # re-raise to prevent the rescue from suppressing
      end
    end

    def revert
      super
      file = @config.pluck_file(@filename)
      file.content = @old_content
      @config.add file
    rescue
      raise TransactionFailedUngracefully.new
    end

    def message
      "edit #{@filename}"
    end
  end
  
end
