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
      puts "you must provide a file or list of files".colorize.red
      exit(-1)
    else

      if options.string["config"] != "current"
        add_to manager, options.string["config"], arguments
      else
        add_to manager, manager.current_config_name, arguments
      end
    end
  end

  private def self.add_to(manager : ConfigManager, config_name : String, files : Array(String))
    config = (manager.try_get_by_name config_name).not_nil!

    files.each do |filename|
      begin
        manager.add_to_current filename
        puts "added #{filename.colorize.yellow} to #{manager.current_config_name.colorize.blue}"
      rescue Transactions::InvalidTransactionError
        puts "add transaction failed for #{filename.colorize.red}, cancelling"
        exit(-1)
      rescue FileAlreadyInConfig
        puts "file #{filename.colorize.red} already in \
          #{manager.current_config_name.colorize.blue}, skipping"
      end
    end
    
    begin
      manager.write_current!
    rescue IO::Error
      puts "couldn't write blob to disk! changes are not saved".colorize.red
      exit(-1)
    end
    
  rescue 
    puts "couldn't fetch config with name #{config_name.colorize.red}"
  end

end
