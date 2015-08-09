require_relative './spec_helper'

RSpec.describe StoredValue do
  let(:override_map) {
    {
      'ubuntu' => 0,
      'production' => 1,
    }
  }

  describe '#new_override_has_priority?' do
    context 'non-existing override' do
      let(:instance) { described_class.new('foo', nil, 'foo') }

      it do
        expect(instance.new_override_has_priority?('itsscript', override_map)).to eq false
      end
    end

    context 'existing more important override' do
      let(:instance) { described_class.new('foo', 'ubuntu', 'foo') }

      it do
        expect(instance.new_override_has_priority?('production', override_map)).to eq true
      end
    end

    context 'existing less important override' do
      let(:instance) { described_class.new('foo', 'production', 'foo') }

      it do
        expect(instance.new_override_has_priority?('ubuntu', override_map)).to eq false
      end
    end

  end
end
