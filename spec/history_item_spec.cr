require "spec"
require "../src/history_item"
require "../src/identity"


describe HistoryItem do

  hist_item = HistoryItem.new Identity.new, HistoryItemType::Create

  Spec.before_each do
    hist_item = HistoryItem.new Identity.new, HistoryItemType::Create
  end

  it "have a revision number" do
    hist_item.revision_number.should_not be_nil
  end

  it "have a change type" do
    hist_item.item_type.should_not be_nil
  end

  it "is able to produce the original contents if the type isn't Create" do
    hist = HistoryItem.new Identity.new, HistoryItemType::Edit, "some_contents"
    hist.original_file_contents.should eq "some_contents"
  end

  it "is able to produce a diff" do
    hist = HistoryItem.new Identity.new, HistoryItemType::Edit, "original_contents", "new_contents"
    hist.diff.should be_a(String)
    hist.diff.not_nil!.size.should_not eq 0
  end

  it "should raise an error if Delete type contains new data" do
    expect_raises(DeleteCantHaveNewContents) do
      hist = HistoryItem.new Identity.new, HistoryItemType::Delete, new_contents: "not empty"
    end
  end

end
