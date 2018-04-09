class Identity
  getter :identifier

  # Automatically generates a new identity on instantiation. Hashes are
  # 128 characters long to make collisions highly unlikely, but no-collision
  # is not guaranteed.
  def initialize
    @identifier = generate_ident
  end

  private def generate_ident : String
  end
end
