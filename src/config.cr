require "./fileset"

class Config
  getter :name

  private VALID_NAMES = /[a-zA-Z0-9_-]*/

  # Creates a new configuration with the given name. *@name* must consist of
  # characters [a-z][A-Z][0-9], -, and _.
  def initialize(@name : String)
    change_name @name
    @is_active = false
  end

  def change_name(new_name : String)
    if verify_filename(new_name) 
      @name = new_name 
    else
      raise InvalidConfigurationName.new
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

class InvalidConfigurationName < Exception
end
