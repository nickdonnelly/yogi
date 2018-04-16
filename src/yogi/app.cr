require "./show"
require "./add"
require "./remove"
require "./new"
require "./delete"

require "commander"

module Yogi

  # Obtain the command line interface for the frontend.
  def self.get_app : Commander::Command
    cli = Commander::Command.new do |cmd|
      cmd.use = "yogi"
      cmd.long = "global configuration manager"
      cmd.run do |_, command|
        puts cmd.help
      end

      cmd.commands.add do |list_current|
        list_current.use = "show"
        list_current.long = "print the given configuration"
        list_current.run do |options, args|
          show(options, args)
        end
      end

      cmd.commands.add get_add_command("a")
      cmd.commands.add get_add_command("add")
      cmd.commands.add get_remove_command("r") 
      cmd.commands.add get_remove_command("remove") 

      cmd.commands.add do |new_config|
        new_config.use = "new [name]"
        new_config.long = "create a new named config (does not switch to the config)"
        new_config.short = new_config.long
        new_config.run do |_, args|
          new_config(args)
        end
      end

      cmd.commands.add do |delete_config|
        delete_config.use = "delete [name]"
        delete_config.long = "delete a config by name"
        delete_config.short = delete_config.long
        delete_config.run do |_, args|
          delete_config(args)
        end
      end
    end

    cli
  end

  def self.capture_command(&block)
    block
  end

  def self.get_add_command(use : String) : Commander::Command
    add = Commander::Command.new(true)
    add.use = use
    add.long = "add a file or list of files (space delimited) to the current config"
    add.short = add.long
    add.flags.add get_config_flag
    add.run do |options, args|
      add(options, args)
    end
    add
  end

  def self.get_remove_command(use : String) : Commander::Command
    remove = Commander::Command.new(true)
    remove.use = use
    remove.long = "remove a file or list of files (space delimited) from the current config"
    remove.short = remove.long
    remove.flags.add get_config_flag
    remove.run do |options, args|
      remove(options, args)
    end
    remove
  end

  def self.get_config_flag : Commander::Flag
    config_flag = Commander::Flag.new
    config_flag.name = "config"
    config_flag.short = "-c"
    config_flag.long = "--config"
    config_flag.default = "current" 
    config_flag.description = "specify a configuration other than the current one."
    config_flag
  end
end
