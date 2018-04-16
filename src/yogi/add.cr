require "../yogi"
require "../transactions"
require "../config_manager"

require "commander"

require "colorize"

module Yogi
  
  def self.add(options : Commander::Options, arguments : Array(String))
    manager = ConfigManager.new
    manager.load_disk_data File.expand_path("~/.yogi/blobs")
    
    if arguments.size == 0
      puts "You must provide a file or list of files.".colorize.red
      exit(-1)
    else
      arguments.each do |filename|
        begin
          manager.add_to_current filename
          puts "added #{filename.colorize.yellow} to #{manager.current_config_name.colorize.blue}"
        rescue Transactions::InvalidTransactionError
          puts "add transaction failed for #{filename.colorize.red}, cancelling"
          exit(-1)
        end
      end
      
      begin
        manager.write_current!
      rescue IO::Error
        puts "couldn't write blob to disk!".colorize.red
        exit(-1)
      end
    end

  end

end
