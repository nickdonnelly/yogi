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

  def delete(filename : String)
    @files.select! do |filemem|
      filemem.filename != filename
    end
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
