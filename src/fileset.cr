require "./identity"
require "./history_item"

class Fileset
  getter :ident
  getter :revision
  
  def initialize
    @ident, @revision = Identity.new, Identity.new
    @files = {} of String => InternalFile
  end

  # Update a files contents by name. Do this, don't manually update files in a set.
  # This bumps the revision number.
  def update_file_contents(filename, new_contents : Bytes | String)
    if @files[filename]?
      @files[filename].contents = new_contents
      update_revision
    else
      raise FilenameNotFound.new
    end
  end

  def add(file : InternalFile)
    @files[file.name] = file
    update_revision
  end

  def count : Int32
    @files.size
  end
  
  def delete(filename : String)
    @files.delete(filename)
    @revision = Identity.new
    update_revision
  end

  def delete(filename : String)
    yield @files.delete(filename)
    update_revision
  end

  # Retrieves the `InternalFile` in the set by the filename (usually the full path).
  def [](index) : InternalFile | Nil
    @files[index]?
  end

  private def update_revision
    @revision = Identity.new
  end

end

# Represents a file with its contents
class InternalFile
  getter :name, :contents, :ident
  getter :history_items

  def initialize(@name : String, @contents : Bytes | String)
    @ident = Identity.new
    @history_items = [] of HistoryItem
    @history_items << HistoryItem.new(@ident, HistoryItemType::Create)
  end

  def contents=(new_contents : String | Bytes)
    @contents = new_contents
    @history_items << HistoryItem.new @ident, HistoryItemType::Edit
    @ident = Identity.new
  end


    
end

class FilenameNotFound < Exception
end
