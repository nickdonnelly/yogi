require "./identity"
class Fileset
  getter :ident
  
  def initialize
    @ident = Identity.new
  end
end
