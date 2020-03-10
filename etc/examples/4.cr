{% if flag?(:png) %}
  require "../../src/ishi/png"
{% else %}
  require "../../src/ishi"
{% end %}
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
  canvas_size(820, 300)
  File.open(File.join(__DIR__, "4.yml")) do |file|
    points = Points.from_yaml(file)
    plots = charts(1, 2)
    plots[0].scatter(points.x, points.z, lc: "#4b03a1")
    plots[1].scatter(points.y, points.z, lc: "#b5367a")
  end
end
