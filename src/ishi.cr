# Graph plotting package with a small API powered by gnuplot.
#
module Ishi
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end

require "./ishi/gnuplot"
