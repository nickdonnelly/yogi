require "../config_manager"

require "commander"

require "colorize"

module Yogi

  def self.revert_command(options : Commander::Options, arguments : Array(String))
    if arguments.size != 1 && !options.bool["last"]
      puts "please only provide 1 argument: the commit number of the change to revert".colorize.red
      puts
      exit -1
    elsif arguments.size > 0 && options.bool["last"]
      puts "you can't provide arguments when --last is passed".colorize.red
      puts
      exit -1
    end

    manager = ConfigManager.new
    manager.load_disk_data File.expand_path("~/.yogi/blobs")

    commit_hash = ""
    if options.bool["last"]
      commit_hash = manager.current_config.latest_commit[0].shortened
    else
      commit_hash = arguments[0]
    end

    new_conf = manager.current_config.revert_commit commit_hash
    manager.write! new_conf
    manager.activate_by_name new_conf.name
    puts "reverted commit #{commit_hash.colorize.yellow}".colorize.green
    puts "reactivated config '#{manager.current_config.name.colorize.yellow}'".colorize.green
    puts
  rescue CommitNotFoundError
    puts "could not find commit #{commit_hash.colorize.yellow}".colorize.red
    puts
    exit -1
  rescue
    puts "error occurred while reverting commit".colorize.red
    puts
    exit -1
  end
end
