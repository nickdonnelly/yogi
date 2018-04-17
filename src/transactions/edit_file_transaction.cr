require "../transactions"

module Transactions

  class EditFileTransaction < Transaction
    getter :old_content

    @old_content : String = ""

    def initialize(@filename : String, @config : Config)
      if !File.exists?(@filename) || !@config.not_nil!.contains?(@filename)
        raise InvalidTransactionError.new
      end
      @old_content = @config.not_nil!.get(@filename).content
      super @config
    end

    # DO NOT USE. this is for deserialization.
    def initialize(@committed : Bool, @config : Config | Nil, @identity : Identity, 
                  @old_content : String, @filename : String)
    end

    def commit
      super
      file = @config.not_nil!.pluck_file(@filename)
      file.content = File.read(@filename)
      @config.not_nil!.add file
    rescue e
      if !e.is_a?(DoubleCommitError)
        revert
      else
        raise DoubleCommitError.new # re-raise to prevent the rescue from suppressing
      end
    end

    def revert
      super
      if @config.not_nil!.contains? @filename
        file = @config.not_nil!.pluck_file(@filename)
        file.content = @old_content
        @config.not_nil!.add file
      else
        @config.not_nil!.add @filename, @old_content
      end
    rescue
      raise TransactionFailedUngracefully.new
    end

    def message
      "edit #{@filename}"
    end
  end
  
end
