require "./yogi/app.cr"

require "commander"

module Yogi

  cli = get_app
  Commander.run(cli, ARGV)

end
