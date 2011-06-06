$:.unshift "../lib"
# usage: rackup
require "sc"

use Rack::ShowExceptions
run Sc