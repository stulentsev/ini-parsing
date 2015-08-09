require_relative './spec_helper'

RSpec.describe ConfigParser do
  let(:instance) { described_class.new(nil) }

  describe '#strip_comments' do
    it 'works' do
      aggregate_failures do
        expect(instance.strip_comments(';this is a comment line')).to eq ''
        expect(instance.strip_comments('key = value; this is end-of-line comment')).to eq 'key = value'
        expect(instance.strip_comments('key = value; this is end-of-line comment; nested comment')).to eq 'key = value'
      end
    end
  end

  describe 'integration test' do
    let(:file) { File.open('test_file.ini') }
    let(:config) { ConfigParser.new(file, ['ubuntu', :production]).call }

    it 'from pdf file' do
      aggregate_failures do
        expect(config.common.paid_users_size_limit).to eq 2147483648
        expect(config.ftp.name).to eq 'hello there, ftp uploading'
        expect(config.http.params).to eq ['array', 'of', 'values']
        expect(config.ftp.lastname).to eq nil
        expect(config.ftp.enabled). to eq false # yes, no, true, false, 1, 0
        expect(config.ftp[:path]).to eq '/etc/var/uploads'
        expect(config.ftp).to eq({name: 'http uploading', path: '/etc/var/uploads', enabled: false})
      end
    end

    describe 'boolean values' do
      let(:content) {
        <<-TEXT
[common]
true1 = yes
true2 = true
true3 = 1

false1 = no
false2 = false
false3 = 0
        TEXT
      }
      let(:file) { StringIO.new(content)}

      it 'parses correctly' do
        aggregate_failures do
          expect(config.true1).to eq true
          expect(config.true2).to eq true
          expect(config.true3).to eq true

          expect(config.false1).to eq false
          expect(config.false2).to eq false
          expect(config.false3).to eq false
        end
      end
    end

  end
end
