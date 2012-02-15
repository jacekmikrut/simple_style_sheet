$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")
require "simple_style_sheet/version"

Gem::Specification.new do |s|
  s.name          = "simple_style_sheet"
  s.version       = SimpleStyleSheet::VERSION
  s.author        = "Jacek Mikrut"
  s.email         = "jacekmikrut.software@gmail.com"
  s.homepage      = "http://github.com/jacekmikrut/simple_style_sheet"
  s.summary       = "Simple style sheet."
  s.description   = "Simple style sheet."

  s.files         = Dir["lib/**/*", "README*", "LICENSE*", "Changelog*"]
  s.require_path  = "lib"
end
