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
end
