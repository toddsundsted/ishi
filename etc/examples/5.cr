require "../../src/ishi"
require "yaml"

class Data
  YAML.mapping(
    d: Array(Array(Float32))
  )
end

# Heatmap.
#
Ishi.new do
  canvas_size(480, 360)
  palette(:inferno)
  File.open(File.join(__DIR__, "5.yml")) do |file|
    data = Data.from_yaml(file)
    imshow(data.d)
  end
  margin(0, 0, 0, 0)
  show_colorbox(false)
  show_border(false)
  show_xtics(false)
  show_ytics(false)
  show_key(false)
end
