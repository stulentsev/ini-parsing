require 'bundler'
Bundler.require(:default)

require_relative './app/imports'

def load_config(file_path, overrides = [])
 file = File.open(file_path)
  ConfigParser.new(file, overrides).call
end


load_config('test_file.ini', [])
