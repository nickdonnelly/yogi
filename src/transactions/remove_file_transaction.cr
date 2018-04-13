require "../transactions"

module Transactions

  class RemoveFileTransaction < Transaction

    @file : (Filemember | Nil) = nil

    def initialize(@filename : String, @config : Config)
      super @config
    end

    def commit
      super
      @file = @config.pluck_file @filename

    end

    def revert
      super
      if @file.nil?
        return
      end
      @config.add @file.not_nil!
    end

    def message
      "remove #{@filename}"
    end
  end

end
