require "../yogi"
require "../config_manager"

require "commander"

require "colorize"

module Yogi

  def self.new_config(args : Array(String))
    if args.size != 1
      puts "you must provide only one argument containing a config name".colorize.red
      puts
      exit(-1)
    end

    create_new_config args[0]
  end

  def self.create_new_config(name : String)
    manager = ConfigManager.new
    manager.set_blob_dir File.expand_path("~/.yogi/blobs")
    if manager.config_exists? name
      puts "config with name #{name.colorize.red} already exists!"
      puts
      exit(-1)
    end

    config = Config.new name
    manager.set_current config
    manager.write_current!

    puts "config #{name} created successfully"
    puts "run #{"yogi switch #{name}".colorize.green} to switch to it"
    puts
  rescue
    puts "couldn't write blob to disk! config was not created".colorize.red
    puts
  end
end
