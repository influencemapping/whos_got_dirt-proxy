require_relative 'app/proxy'

use Rack::Deflater
run WhosGotDirt::Proxy
