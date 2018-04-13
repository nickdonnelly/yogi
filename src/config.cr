require "cannon"

class Config
  include Cannon::Auto

  getter :name
  getter :files

  private VALID_NAMES = /[a-zA-Z0-9_-]*/

  # Creates a new configuration with the given name. *@name* must consist of
  # characters [a-z][A-Z][0-9], -, and _.
  def initialize(@name : String, @is_active : Bool = false, 
                 @files : Array(Filemember) = [] of Filemember)
    change_name @name
  end

  # Changes the name. This __does not__ guarantee the deletion of blobs
  # with the old name on disk.
  def change_name(new_name : String)
    if verify_filename(new_name) 
      @name = new_name 
    else
      raise InvalidConfigurationName.new
    end
  end

  def add(filename : String, contents : String)
    @files << Filemember.new filename, contents
  end

  def add(file : Filemember)
    @files << file
  end

  def delete(filename : String)
    @files.reject! do |filemem|
      filemem.filename == filename
    end
  end

  def pluck_file(filename : String) : Filemember
    if !contains?(filename)
      raise FileNotInConfig.new
    end

    f : Filemember | Nil = nil
    @files.reject! do |filemem|
      if filemem.filename == filename
        f = filemem
      end
      filemem.filename == filename
    end

    f.not_nil!
  end

  def deactivate!
    @files.each do |filemem|
      begin
        File.delete filemem.filename
      rescue Errno
        #raise ConfigDeactivationFailure.new
      end
    end
  end

  def activate!
    @files.each do |filemem|
      File.write filemem.filename, filemem.content
    end
  end

  def contains?(filepath : String) : Bool
    @files.each do |filemem|
      if filemem.filename == filepath
        return true
      end
    end
    false
  end

  private def verify_filename(name : String) : Bool
    matches = VALID_NAMES.match name
    if matches.nil?
      false
    else
      matches[0].size == name.size && name.size > 0
    end
  end

end

struct Filemember
  property :content
  property :filename

  include Cannon::Auto

  def initialize(@filename : String, @content : String)
  end
end

class InvalidConfigurationName < Exception
end

class FileNotInConfig < Exception
end
