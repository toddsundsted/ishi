{% if flag?(:png) %}
  require "../../src/ishi/png"
{% else %}
  require "../../src/ishi"
{% end %}

# Plot data points and the equation of a line.
#
Ishi.new do
  canvas_size(480, 360)
  min = 1.2
  step = 0.5
  n = 25
  x = (1..n).map { |i| min + i * step}
  y = (1..n).map { rand }
  plot(x, y, title: "a box plot!", style: :boxes)
    .boxwidth(step)
end
