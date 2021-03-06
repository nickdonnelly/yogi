require "../yogi"
require "../config_manager"

require "commander"

require "colorize"

module Yogi
  
  def self.show_command(options : Commander::Options, arguments : Array(String))
    manager = ConfigManager.new
    manager.load_disk_data File.expand_path("~/.yogi/blobs")
    
    if arguments.size == 0
      print_configs manager
    else
      print_individual_config manager, arguments[0]
    end

  end

  private def self.print_configs(manager : ConfigManager)
    list = manager.get_config_list
    current_name = manager.current_config_name
    list.each do |config_name|
      if config_name == current_name
        puts "* #{config_name} (current)".colorize.green
      else
        puts "> #{config_name}"
      end
    end
    puts
  end

  private def self.print_individual_config(manager : ConfigManager, config_name : String)
    config = if config_name == "current" 
               config_name = manager.current_config.name
               manager.current_config
             else
               manager.try_get_by_name config_name
             end
    not_found = "couldn't fetch config '#{config_name}'".colorize.red
    if config.nil?
      puts not_found
    end
    config = config.not_nil!

    puts "name: #{config_name.colorize.blue}"
    puts "latest revision: #{print_commit config.latest_commit}"
    puts "current configuration contains the following files:"
    
    if config.files.size == 0
      puts "<no files>".colorize.yellow
      return
    end

    config.files.sort! do |a, b|
      a.filename.compare b.filename
    end

    config.files.each do |filemem|
      puts "  #{filemem.filename.colorize.green} "
    end
    puts
  rescue ConfigFetchError
    puts not_found
    puts
  end

end
