require "../transactions"

module Transactions

  class RemoveFileTransaction < Transaction

    @file : (Filemember | Nil) = nil

    def initialize(@filename : String, @config : Config)
      super @config
    end

    # DO NOT USE. this is for deserialization.
    def initialize(@committed : Bool, @config : Config, @identity : Identity,
                   @file : Filemember | Nil, @filename : String)
    end

    def commit
      super
      @file = @config.not_nil!.pluck_file @filename

    end

    def revert
      super
      if @file.nil?
        return
      end
      @config.not_nil!.add @file.not_nil!
    end

    def message
      "remove #{@filename}"
    end
  end

end
