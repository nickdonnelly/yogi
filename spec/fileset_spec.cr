require "spec"
require "../src/fileset"

describe Fileset do
  file : InternalFile = InternalFile.new "", ""
  set : Fileset = Fileset.new

  Spec.before_each do
    file = InternalFile.new "/path/filename", "some_contents"
    set = Fileset.new
  end

  it "has an associated identifier" do
    set.ident.should_not be_nil
  end

  it "should accept new files" do
    set.add file
    set.count.should eq 1
  end

  it "should allow indexing by filename" do
    #file = InternalFile.new("/path/filename", "some_contents")
    set.add file
    set["/path/filename"].should be(file)
  end

  it "should deletetion of files" do
    set.add file
    set.delete "/path/filename"
    set.count.should eq 0
  end

  it "should let deleted files be handled in a block" do
    set.add file
    set.delete "/path/filename" do |file|
      file.not_nil!.name.should be "/path/filename"
    end
  end

  it "should let files be updated to a new version" do
    set.add file

    set.update_file_contents "/path/filename", "new_contents"
    set["/path/filename"].not_nil!.contents.should eq "new_contents"
  end

  it "should raise an error if you update a file that doesn't exist" do
    expect_raises(FilenameNotFound) do
      set.update_file_contents "/doesnt/exist", "new_contents"
    end
  end

  it "should return nil when a non-existant file is indexed" do
    set["doesntexist"].should be_nil
  end

end

describe InternalFile do
  file : InternalFile = InternalFile.new "", ""

  Spec.before_each do
    file = InternalFile.new "/path/filename", "some_contents"
  end

  it "should update identity on change" do
    start_ident = file.ident
    file.contents = "new_contents"
    file.ident.should_not be(start_ident)
  end

  it "should update contents on change" do
    file.contents = "new_contents"
    file.contents.should eq "new_contents"
  end

  # TODO: diffs on update
end
