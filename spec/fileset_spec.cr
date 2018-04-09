require "spec"
require "../src/fileset"

describe Fileset do
  it "has an associated identifier" do
    set = Fileset.new
    set.ident.should_not be_nil
  end
end
