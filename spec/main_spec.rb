require_relative './spec_helper'

RSpec.describe ConfigParser do
  let(:file) { File.open('../test_file.ini') }
  let(:instance) { ConfigParser.new(file, ['ubuntu', :production]) }

  it 'from pdf file' do

  end
end
