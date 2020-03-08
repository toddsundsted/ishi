require "./spec_helper"

Spectator.describe Ishi do
  describe "::VERSION" do
    it "should return the version" do
      version = YAML.parse(File.read(File.join(__DIR__, "..", "shard.yml")))["version"].as_s
      expect(Ishi::VERSION).to eq(version)
    end
  end

  describe ".new" do
    it "creates a new instance" do
      described_class.new
    end

    it "takes a block and yields a new instance" do
      described_class.new do
      end
    end
  end

  describe "#charts" do
    subject { described_class.new }

    it "creates multiple subcharts" do
      expect(subject.charts(2, 1).size).to eq(2)
    end

    it "engages multiplot mode" do
      subject.charts(2, 1)
      expect(subject.show).to have("set multiplot layout 2,1", "unset multiplot")
    end

    it "extends subcharts" do
      plots = ["sin(x)", "cos(x)"]
      subject.charts(2, 1) do
        plot(plots.shift)
      end
      subject.charts(3, 1)
      expect(subject.show).to have("plot sin(x)", "plot cos(x)")
      expect(subject.size).to eq(3)
    end

    it "truncates subcharts" do
      plots = ["sin(x)", "cos(x)", "tan(x)"]
      subject.charts(3, 1) do
        plot(plots.shift)
      end
      subject.charts(2, 1)
      expect(subject.show).to have("plot sin(x)", "plot cos(x)")
      expect(subject.size).to eq(2)
    end

    it "forbids invoking #charts on a subchart" do
      chart = subject.charts(1, 1).first
      expect{chart.charts(1, 1)}.to raise_error(NotImplementedError)
    end

    it "forbids invoking #show on a subchart" do
      chart = subject.charts(1, 1).first
      expect{chart.show}.to raise_error(NotImplementedError)
    end
  end

  describe "#plot" do
    subject { described_class.new }

    it "plots y values" do
      expect(subject.plot([1, 2, 3]).show).to have(/^plot .* with lines$/, "0 1", "1 2", "2 3")
    end

    it "plots x and y values" do
      expect(subject.plot([1, 2, 3], [1, 2, 3]).show).to have(/^plot .* with points$/, "1 1", "2 2", "3 3")
    end

    it "plots x, y and z values" do
      expect(subject.plot([0, 1, 2], [1, 2, 3], [0, 1, 0]).show).to have(/^splot .* with points$/, "0 1 0", "1 2 1", "2 3 0")
    end

    it "accepts arrays of numbers of different types" do
      subject.plot([1, 2, 3], [3, 2, 1], [1.0, 2.0, 3.0]).show
      subject.plot([1, 2, 3], [1.0, 2.0, 3.0]).show
    end
  end

  describe "#scatter" do
    subject { described_class.new }

    it "scatter plots x and y values" do
      expect(subject.scatter([1, 2, 3], [1, 2, 3]).show).to have(/^plot .* with dots$/, "1 1", "2 2", "3 3")
    end

    it "scatter plots x, y and z values" do
      expect(subject.scatter([0, 1, 2], [1, 2, 3], [0, 1, 0]).show).to have(/^splot .* with dots$/, "0 1 0", "1 2 1", "2 3 0")
    end
  end

  describe "#imshow" do
    subject { described_class.new }

    it "displays an image" do
      expect(subject.imshow([[1, 2], [3, 4]]).show).to have(/^plot .* matrix with image$/, "1 2", "3 4")
    end
  end

  describe "#canvas_size" do
    subject { described_class.new }

    it "sets the size of the chart canvas" do
      expect(subject.canvas_size(320, 200).show).to have(/size 320,200/)
    end
  end
end
