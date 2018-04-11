require "spec"
require "../../src/util/diff_computer"

include DiffComputer

describe DiffComputer do
  context "compute_diff" do
    
  end

  context "#lcs_len" do
    pending "returns the right length" do
      a = "abcdefghijkl"
      b = "acdefgjkl"

      x = lcs_len(a, b)
      x.should eq b.size
    end
  end
end
