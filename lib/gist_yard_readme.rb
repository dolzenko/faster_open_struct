require "yard"
YARD.parse(File.expand_path("../faster_open_struct.rb", __FILE__))
File.open(File.expand_path("../../README.md", __FILE__), "w") do |f|
  f.write(P("Faster::OpenStruct").docstring)
end