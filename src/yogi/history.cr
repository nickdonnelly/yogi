require "../yogi"
require "../config_manager"

require "commander"

require "colorize"

module Yogi
  
  def self.history_command(options : Commander::Options, arguments : Array(String))
    max = options.int["num_entries"]
    manager = ConfigManager.new 
    manager.load_disk_data File.expand_path("~/.yogi/blobs")

    config_name = options.string["config"]
    if config_name == "current"
      print_history(manager.current_config, max)
    else
      config = manager.try_get_by_name config_name
      print_history(config.not_nil!, max)
    end
  rescue
    puts "could not fetch config '#{config_name}'".colorize.red
    exit -1
  end

  private def self.print_history(config : Config, max : Int32 | Int64)
    if config.commit_identities.size == 0
      puts "<no commit history>".colorize.yellow
      exit 0
    end

    config.commit_identities.last(max).reverse.each do |commit|
      if commit[1].starts_with? "add"
        puts "#{commit[0].shortened.colorize.yellow} - #{commit[1].colorize.green}"
      elsif commit[1].starts_with? "edit"
        puts "#{commit[0].shortened.colorize.yellow} - #{commit[1].colorize.blue}"
      else
        puts "#{commit[0].shortened.colorize.yellow} - #{commit[1].colorize.red}"
      end
    end
  end
end
