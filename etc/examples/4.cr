require "../../src/ishi"
require "yaml"

class Points
  YAML.mapping(
    x: Array(Float32),
    y: Array(Float32),
    z: Array(Float32)
  )
end

# Scatter plot.
#
Ishi.new do
  canvas_size(480, 360)
  view(80, 20)
  File.open(File.join(__DIR__, "4.yml")) do |file|
    points = Points.from_yaml(file)
    scatter(points.x, points.y, points.z)
  end
end
