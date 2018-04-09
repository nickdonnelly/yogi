require "./identity"
class Fileset
  getter :ident
  
  def initialize
    @ident = Identity.new
    @files = {} of String => InternalFile
  end

  def update_file_contents(filename, new_contents : Bytes | String)
    if @files[filename]?
      @files[filename].contents = new_contents
    else
      raise FilenameNotFound.new
    end
  end

  def add(file : InternalFile)
    @files[file.name] = file
  end

  def count : Int32
    @files.size
  end
  
  def delete(filename : String)
    @files.delete(filename)
  end

  def delete(filename : String)
    yield @files.delete(filename)
  end

  # Retrieves the `InternalFile` in the set by the filename (usually the full path).
  def [](index) : InternalFile | Nil
    @files[index]?
  end

end

# Represents a file with its contents
class InternalFile
  getter :name, :contents, :ident

  def initialize(@name : String, @contents : Bytes | String)
    @ident = Identity.new
  end

  def contents=(new_contents : String | Bytes)
    @contents = new_contents
    @ident = Identity.new
  end
    
end

class FilenameNotFound < Exception
end
