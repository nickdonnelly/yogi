require "./show"

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
    end

    cli
  end

  def self.capture_command(&block)
    block
  end
end
