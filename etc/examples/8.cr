{% if flag?(:png) %}
  require "../../src/ishi/png"
{% else %}
  require "../../src/ishi"
{% end %}

# Scatter plot with variable circle size.
Ishi.new do
  canvas_size(480, 360)
  n = 10
  x = (1..n).map { rand }
  y = (1..n).map { rand }
  size = (1..n).map { rand * 10 }
  scatter(x,y, pointsize: size, pt: "o", style: :points)
end
