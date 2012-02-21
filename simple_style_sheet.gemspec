$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")
require "simple_style_sheet/version"

Gem::Specification.new do |s|
  s.name          = "simple_style_sheet"
  s.version       = SimpleStyleSheet::VERSION
  s.author        = "Jacek Mikrut"
  s.email         = "jacekmikrut.software@gmail.com"
  s.homepage      = "http://github.com/jacekmikrut/simple_style_sheet"
  s.summary       = "Parses a CSS-like Hash style sheet and allows searching for property values of HTML-like tags."
  s.description   = "Parses a CSS-like Hash style sheet and allows searching for property values of HTML-like tags. Tag and property names, as well as their meaning, are up to the gem user."

  s.files         = Dir["lib/**/*", "README*", "LICENSE*", "Changelog*"]
  s.require_path  = "lib"

  s.add_development_dependency "rspec", "~> 2.0"
end
