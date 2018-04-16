require "time"
require "openssl"

require "cannon"

class Identity

  include Cannon::Auto

  def_clone

  getter :identifier

  @identifier : String

  # Automatically generates a new identity on instantiation. Hashes are
  # 64 characters long to make collisions highly unlikely, but no-collision
  # is not guaranteed.
  def initialize(@identifier = generate_ident)
  end

  def shortened
    @identifier[0..5]
  end

  private def generate_ident : String
    seed = Time.now.nanosecond
    hasher = OpenSSL::Digest.new("SHA256")
    hasher.update(seed.to_s)
    hasher.hexdigest
  end
end
