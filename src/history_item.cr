require "./identity"
require "./util/diff_computer"

require "process"
require "io"


class HistoryItem
  getter :revision_number, :item_type, :diff

  include DiffComputer

  @diff : String

  def initialize(@revision_number : Identity, @item_type : HistoryItemType, 
                 @original_contents : String = "", @new_contents : String = "")
    if item_type == HistoryItemType::Delete && new_contents.size > 0
      raise DeleteCantHaveNewContents.new
    end

    @diff = compute_diff @original_contents, @new_contents
  end

  def original_file_contents : String
    @original_contents
  end


end

enum HistoryItemType
  Edit = 0
  Create = 1
  Delete = 2
end

class DeleteCantHaveNewContents < Exception
end
