require "spec"
require "../src/identity"

describe Identity do
  it "should have a string identifier" do
    ident = Identity.new
    ident.identifier.should be_a(String)
  end

  it "should have a 64 character hexadecimal identifier" do
    ident = Identity.new
    regex = /[0-9a-f]{64}/i
    matches = regex.match(ident.identifier)
    matches.not_nil![0].size.should eq(64)
  end

  it "shouldn't produce the identifier twice in a row" do
    ident = Identity.new
    ident2 = Identity.new
    ident.shortened.should_not be ident2.shortened
  end

end
