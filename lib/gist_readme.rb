#!/usr/bin/env ruby
#
# Usage: ./gist_readme.rb source_file.rb [README.md]
#
# Extracts first comment block from source_file.rb into README.md file
#
#
raise "source_file should be specified" if ARGV.empty?

File.open(File.expand_path(File.join("../", ARGV[1] || "README.md") , __FILE__), "w") do |f|
  first_comment = []
  IO.read(File.expand_path(File.join("../", ARGV[0]), __FILE__)).each_line do |l|
    if l =~ /\s*#/
      first_comment << l.sub(/^\s*#\s/, "").rstrip
    elsif !first_comment.empty?
      break
    end
  end
  f.write(first_comment.join("\n"))
end