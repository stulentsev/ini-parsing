class StoredValue < Struct.new(:value, :override, :overridden_value)
  def new_override_has_priority?(new_override, priority_map)
    return false unless priority_map[new_override]
    return true unless override

    priority_map[new_override].to_i > priority_map[override].to_i
  end
end
