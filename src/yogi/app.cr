require "./*"

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
        list_current.long = "print the given configuration or a list of all configurations"
        list_current.short = list_current.long
        list_current.run do |options, args|
          show_command(options, args)
        end
      end

      cmd.commands.add get_switch_command("s")
      cmd.commands.add get_switch_command("switch")
      cmd.commands.add get_add_command("a")
      cmd.commands.add get_add_command("add")
      cmd.commands.add get_remove_command("r") 
      cmd.commands.add get_remove_command("remove") 
      cmd.commands.add get_update_command("u") 
      cmd.commands.add get_update_command("update") 
      cmd.commands.add do |changes|
        changes.use = "changes"
        changes.long = "list the on disk changes from the current config"
        changes.short = changes.long
        changes.run do |options, args|
          changes_command(options, args)
        end
      end

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

      cmd.commands.add get_hist_command("h")
      cmd.commands.add get_hist_command("hist")
    end

    cli
  end

  def self.capture_command(&block)
    block
  end

  def self.get_hist_command(use : String) : Commander::Command
    hist = Commander::Command.new(true)
    hist.use = use
    hist.long = "show the recent history of the current config"
    hist.short = hist.long
    hist.flags.add get_config_flag
    hist.flags.add do |max_entries|
      max_entries.name = "num_entries"
      max_entries.short = "-n"
      max_entries.long = "--num-entries"
      max_entries.default = 10
      max_entries.description = "the maximum number of entries to display."
    end
    hist.run do |options, args|
      history_command(options, args)
    end
    hist
  end

  def self.get_add_command(use : String) : Commander::Command
    add = Commander::Command.new(true)
    add.use = use
    add.long = "add a file or list of files (space delimited) to the current config"
    add.short = add.long
    add.flags.add get_config_flag
    add.run do |options, args|
      add_command(options, args)
    end
    add
  end

  def self.get_update_command(use : String) : Commander::Command
    update = Commander::Command.new(true)
    update.use = use
    update.long = "update a file, list of files, or all files that have changed on disk"
    update.short = update.long
    update.flags.add get_config_flag
    update.run do |options, args|
      update_file(options, args)
    end
    update
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

  def self.get_switch_command(use : String) : Commander::Command
    switch = Commander::Command.new(true)
    switch.use = use
    switch.long = "switch to the given config"
    switch.short = switch.long
    switch.run do |options, args|
      activate_command(options, args)
    end
    switch
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
