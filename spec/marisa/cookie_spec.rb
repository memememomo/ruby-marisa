require 'rspec'
require 'marisa/cookie/request'

describe 'Marisa::Cookie::Request' do

  subject(:req) { Marisa::Cookie::Request.new }

  context 'Request cookie as string' do
    it do
      req.name = '0'
      req.value = 'ba =r'
      expect(req.to_s).to eq('0="ba =r"')
    end
  end

  context 'Request cookie without value as string' do
    it do
      req.name = 'foo'
      expect(req.to_s).to eq('foo=')
    end

    it do
      req.name = 'foo'
      req.value = ''
      expect(req.to_s).to eq('foo=')
    end
  end

  context "Empry requset cookie" do
    it do
      expect(Marisa::Cookie::Request.parse).to match_array []
    end
  end

  context "Parse normal request cookie (RFC 2965)" do
    subject(:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=bar; $Path="/test"')}
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('bar') }
    it { expect(cookies[1]).to eq(nil) }
  end

  context "Parse request cookies from multiple header value (RFC 2965)" do
    subject(:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=bar; $Path="/test", $Version=0; baz=yada; $Path="/test"')}
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('bar') }
    it { expect(cookies[1].name).to eq('baz') }
    it { expect(cookies[1].value).to eq('yada') }
    it { expect(cookies[2]).to eq(nil) }
  end

end