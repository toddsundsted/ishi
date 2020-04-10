{% if flag?(:png) %}
  require "../../src/ishi/png"
{% else %}
  require "../../src/ishi"
{% end %}
include Ishi

# Bar chart with fixed box width and custom fill style
Ishi.new do
  canvas_size(480, 360)
  min = 1.2
  step = 0.5
  n = 25
  x = (1..n).map { |i| min + i * step }
  y = (1..n).map { rand }
  plot(x, y,
    title: "a box plot!",
    style: :boxes,
    fs: FillStyle::Solid.new(0.2)
  ).boxwidth(step).show_border(true)
end
