require "../config_manager"

require "file"
require "colorize"

require "commander"

module Yogi

  def self.activate_command(options : Commander::Options, arguments : Array(String))
    manager = ConfigManager.new
    manager.load_disk_data File.expand_path("~/.yogi/blobs")
    if arguments.size > 1
      puts "only provide 1 argument: the name of the config to switch to".colorize.red
      exit -1
    end
    
    config_name = arguments[0]

    if manager.current_config.has_changes?
      print "there are changes in the current config. switching the configuration will cause \
        these changes to be lost. continue? (y/n) ".colorize.red
        answer = gets.not_nil![0]
      if answer != "y"
        exit 0
      end
    end

    manager.activate_by_name config_name
  rescue ConfigFetchError
    puts "couldn't fetch config with name #{config_name.colorize.blue}".colorize.red
    exit -1
  rescue ConfigActivationFailure
    puts "couldn't activate config #{config_name.colorize.blue}".colorize.red
    exit -1
  rescue
    puts "an unknown error occurred".colorize.red
    exit -1
  end
end
