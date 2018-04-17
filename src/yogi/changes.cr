require "../config_manager"

require "file"
require "colorize"

require "commander"

module Yogi

  def self.changes_command(options : Commander::Options, arguments : Array(String))
    manager = ConfigManager.new
    manager.load_disk_data File.expand_path("~/.yogi/blobs")

    # count the changes in case there's none
    changes = 0
    commit = manager.@current_config.latest_commit
    puts "last revision: #{print_commit commit}"
    manager.@current_config.files.each do |filemem|
      # First check for deletion
      if !File.file? filemem.filename
        puts "- file #{filemem.filename} deleted on disk".colorize.red
        changes += 1
        next
      end

      if File.read(filemem.filename) != filemem.content
        puts "* file #{filemem.filename} edited on disk".colorize.blue
        changes += 1
        next
      end
    end

    if changes == 0
      puts "<no changes found for #{manager.@current_config.name.colorize.blue}\
          #{">".colorize.yellow}".colorize.yellow
    end
  end

end
