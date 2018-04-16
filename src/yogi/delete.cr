require "../blob_provider"

require "commander"

require "colorize"

module Yogi
  def self.delete_config(arguments : Array(String))
    if arguments.size != 1
      puts "you can only provide 1 argument: the name of a config".colorize.red
      exit -1
    end
    
    delete_by_name arguments[0]
  end

  def self.delete_by_name(name : String)
    blob_provider = BlobProvider.new File.expand_path("~/.yogi/blobs")

    print "this will attempt to delete the config #{name}. \
      are you sure you want to continue? (y/n) "
    line = gets.not_nil!

    if line[0] != 'y'
      exit 0
    end

    blob_provider.remove_blob name
    puts "successfully deleted config #{name.colorize.blue}"
  rescue BlobDoesntExistError
    puts "could not find config blob with name #{name}".colorize.red
    exit -1
  end

end
