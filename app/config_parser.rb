require 'ostruct'

class ConfigParser
  attr_reader :overrides, :io

  def initialize(io, overrides = [])
    @overrides = overrides.map(&:to_s)
    @io = io
  end

  def call
    io.each_line do |original_line|
      line = strip_comments(original_line)

      if section_heading?(line)
        start_new_section(parse_section_name(line))
      elsif key_value_pair?(line)
        add_kv(parse_kv(line))
      else
        puts "unrecognized format of the line: #{original_line}"
      end
    end
  end

end
