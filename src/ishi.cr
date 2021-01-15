require "./ishi/gnuplot"
require "./ishi/term"

# Graph plotting package with a small API powered by gnuplot.
#
# See `Base` for documentation on supported methods.
#
module Ishi
  # :nodoc:
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  # :nodoc:
  class Qt < Term
    def initialize(**ignored)
      super("qt persist")
    end
  end

  # :nodoc:
  @@default = Qt

  # Creates a new instance. An `IO` for output may be specified.
  #
  # ```
  # ishi = Ishi.new
  # ishi.plot([1, 2, 3, 4])
  # ishi.show
  # ```
  #
  def self.new(io : IO = STDOUT)
    @@default.new(io: io)
  end

  # Creates a new instance.
  #
  # Yields to the supplied block with the new instance as the implicit
  # receiver. Automatically invokes `#show` before returning. An `IO`
  # for output may be specified. Any *options* are passed to `#show`.
  #
  # ```
  # Ishi.new do
  #   plot([1, 2, 3, 4])
  # end
  # ```
  #
  def self.new(io : IO = STDOUT, **options)
    @@default.new(io: io).tap do |instance|
      with instance yield
      instance.show(**options)
    end
  end
end
