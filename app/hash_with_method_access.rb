class HashWithMethodAccess < Hash
  def method_missing(name)
    self[name]
  end
end
