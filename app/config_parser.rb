require 'ostruct'

class ConfigParser
  attr_reader :overrides, :io

  attr_accessor :current_section_name

  def initialize(io, overrides = [])
    @overrides = prioritize_overrides(overrides)
    @io = io
  end

  def call
    parse

    ap storage
    storage
  end

  def parse
    io.each_line do |original_line|
      line = strip_comments(original_line).strip
      next if line.empty?

      if (heading = parse_section_name(line))
        start_new_section(heading)
      elsif (pair = key_value_pair(line))
        key, value = pair
        add_kv_with_overrides(key, value)
      else
        puts "unrecognized format of the line: #{original_line}"
      end
    end
  end

  def strip_comments(line)
    line.gsub(/;.*$/, '')
  end

  def parse_section_name(line)
    rgx = /^\[(?<name>\w+)\]$/
    m = rgx.match(line)
    return false unless m

    m[:name]
  end

  def start_new_section(name)
    self.current_section_name = name
  end

  def key_value_pair(line)
    res = line.split('=')
    return nil if res.length != 2
    k, v = res.map(&:strip)
    [k, strip_quotes(v)]
  end

  def add_kv_with_overrides(key, value)
    key, override = parse_key_with_override(key)

    stored_value = get_value(key)
    if stored_value
      if override && stored_value.new_override_has_priority?(override, overrides)
        stored_value.override = override
        stored_value.overridden_value = value
      else
        stored_value.value = value
      end
    else
      set_value(key, StoredValue.new(value, override, value))
    end
  end

  def parse_key_with_override(str)
    rgx = /(?<name>\w+)(\<(?<override>\w+)\>)?/
    m = rgx.match(str)
    raise "unrecognized key format: #{str.inspect}" unless m

    [m[:name], m[:override]].compact
  end

  private

  def storage
    @storage ||= Hash.new {|hash, key| hash[key] = {} }
  end

  def get_value(key)
    storage[current_section_name][key]
  end

  def set_value(key, value)
    storage[current_section_name][key] = value
  end

  def prioritize_overrides(overrides)
    overrides.map(&:to_s).each.with_index.each_with_object({}) do |(cur, idx), memo|
      memo[cur] = idx # if override occurs twice, the latter will have priority. Example: [ubuntu, production, ubuntu]
    end
  end

  def strip_quotes(str)
    str.gsub(/^[\'\"]/, '').gsub(/[\'\"]$/, '')
  end


end
