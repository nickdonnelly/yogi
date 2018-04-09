require "spec"
require "../src/identity"

describe Identity do
  it "should have a hash identifier" do
    ident = Identity.new
    ident.identifier.should_not be_a(String)
  end

end
