require "../yogi"
require "../transactions"
require "../config_manager"

require "commander"

require "colorize"

module Yogi

  def self.remove(options : Commander::Options, arguments : Array(String))
    manager = ConfigManager.new
    manager.load_disk_data File.expand_path("~/.yogi/blobs")
    
    if arguments.size == 0
      puts "you must provide a file or list of files".colorize.red
      puts
      exit(-1)
    else
      if options.string["config"] != "current"
        remove_from manager, options.string["config"], arguments
      else
        remove_from manager, manager.current_config_name, arguments
      end
    end
  end

  def self.remove_from(manager : ConfigManager, config_name : String, files : Array(String))
    config = manager.try_get_by_name config_name
    manager.set_current config.not_nil!

    files.each do |filename|
      begin
        manager.remove_from_current filename
        puts "removed #{filename.colorize.yellow} from #{manager.current_config_name.colorize.blue}"
      rescue Transactions::InvalidTransactionError
        puts "remove transaction failed for file #{filename.colorize.red}, cancelling"
        exit(-1)
      rescue FileNotInConfig 
        puts "file #{filename.colorize.red} not found in \
          #{manager.current_config_name.colorize.blue}, skipping"
      end
    end
    
    begin
      manager.write_current!
      puts
    rescue IO::Error
      puts "couldn't write blob to disk! changes are not saved".colorize.red
      puts
      exit(-1)
    end
    
  rescue 
    puts "couldn't fetch config with name #{config_name.colorize.red}"
      puts
  end

end
