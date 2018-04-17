require "../config_manager"

require "file"
require "colorize"

require "commander"

module Yogi

  def self.update_file(options : Commander::Options, arguments : Array(String))
    manager = ConfigManager.new
    manager.load_disk_data File.expand_path("~/.yogi/blobs")
    config_name = options.string["config"]

    if config_name != "current"
      config = manager.try_get_by_name config_name
      manager.set_current config.not_nil!
    end

    if arguments.size == 1 && arguments[0] == "all"
      self.update_all manager
    else
      self.update arguments, manager
    end

  rescue
    puts "could not fetch config with name #{config_name}".colorize.red
    exit -1
  end

  def self.update_all(manager : ConfigManager)
    manager.current_config.files.each do |filemem|
      if !File.file? filemem.filename 
        begin
          manager.remove_from_current filemem.filename
          manager.write_current!
          puts delete_msg(filemem.filename, manager.current_config_name)
        rescue
          puts delete_fail_msg(filemem.filename)
        end
        next

      elsif File.read(filemem.filename) != filemem.content
        begin
          manager.update_current filemem.filename
          manager.write_current!
          puts update_msg(filemem.filename, manager.current_config_name)
        rescue
          puts update_fail_msg(filemem.filename)
          next
        end
      end
    end
  end

  def self.update(args : Array(String), manager : ConfigManager)
    args.each do |filename|
      filename = File.expand_path(filename)
      if !File.file?(filename) && manager.current_contains?(filename)
        begin
          manager.remove_from_current filename
          manager.write_current!
          puts delete_msg(filename, manager.current_config_name)
        rescue
          puts delete_fail_msg(filename)
        end
        next
      elsif !manager.current_contains? filename
        puts not_in_config_msg(filename, manager.current_config_name)
        next

      elsif File.read(filename) != manager.current_config.get(filename).content
        begin
          manager.update_current filename
          manager.write_current!
          puts update_msg(filename, manager.current_config_name)
        rescue
          puts update_fail_msg(filename)
        end
      end

    end
  end

  private def self.not_in_config_msg(filename : String, config_name : String) : String
    "> file '#{filename.colorize.yellow}' is not in \
      config #{config_name.colorize.blue}, skipping it"
  end

  private def self.delete_msg(filename : String, config_name : String) : String
    "- removed file '#{filename}' from #{config_name.colorize.blue}".colorize.light_magenta.to_s
  end

  private def self.update_msg(filename : String, config_name : String) : String
    "* updated '#{filename.colorize.yellow}' in #{config_name.colorize.blue}"
  end

  private def self.delete_fail_msg(filename : String) : String
    "->could not complete delete transaction for '#{filename}'".colorize.red.to_s
  end

  private def self.update_fail_msg(filename : String) : String
    "->could not complete update transaction for '#{filename}'".colorize.red.to_s
  end

end
