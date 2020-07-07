require "../spec_helper"
require "../../src/ishi/term"

# Subclass `Ishi::Term` to discard `abstract`.

class FooBar < Ishi::Term
  def initialize(io : IO = STDOUT)
    super("foo bar", io)
  end

  def show(**options)
    super(**options).tap do |lines|
      lines.each do |line|
        io.puts line
      end
    end
  end
end

Spectator.describe Ishi::Term do
  let(io) { IO::Memory.new }
  subject { FooBar.new(io) }

  describe "#show" do
    it "sets up the terminal" do
      subject.show
      expect(io.to_s).to match(/set term foo bar/)
    end

    it "sets the size of the terminal canvas" do
      subject.canvas_size(20, 20)
      subject.show
      expect(io.to_s).to match(/set term foo bar size 20,20/)
    end

    it "engages multiplot mode" do
      subject.charts(2, 2)
      subject.show
      expect(io.to_s).to match(/set multiplot layout 2,2/)
    end
  end
end
