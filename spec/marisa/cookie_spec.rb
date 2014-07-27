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

  context 'Empry requset cookie' do
    it do
      expect(Marisa::Cookie::Request.parse).to match_array []
    end
  end

  context 'Parse normal request cookie (RFC 2965)' do
    subject(:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=bar; $Path="/test"')}
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('bar') }
    it { expect(cookies[1]).to eq(nil) }
  end

  context 'Parse request cookies from multiple header value (RFC 2965)' do
    subject(:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=bar; $Path="/test", $Version=0; baz=yada; $Path="/test"')}
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('bar') }
    it { expect(cookies[1].name).to eq('baz') }
    it { expect(cookies[1].value).to eq('yada') }
    it { expect(cookies[2]).to eq(nil) }
  end

  context 'Parse request cookie (netscape)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('CUSTOMER=WILE_E_COYOTE') }
    it { expect(cookies[0].name).to eq('CUSTOMER') }
    it { expect(cookies[0].value).to eq('WILE_E_COYOTE') }
    it { expect(cookies[1]).to eq(nil) }
  end

  context 'Parse multiple request cookies (Netscape)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('CUSTOMER=WILE_E_COYOTE; PART_NUMBER=ROCKET_LAUNCHER_0001') }
    it { expect(cookies[0].name).to eq('CUSTOMER') }
    it { expect(cookies[0].value).to eq('WILE_E_COYOTE') }
    it { expect(cookies[1].name).to eq('PART_NUMBER') }
    it { expect(cookies[1].value).to eq('ROCKET_LAUNCHER_0001') }
    it { expect(cookies[2]).to eq(nil) }
  end

  context 'Parse multiple request cookies from multiple header values (Netscape)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('CUSTOMER=WILE_E_COYOTE, PART_NUMBER=ROCKET_LAUNCHER_0001') }
    it { expect(cookies[0].name).to eq('CUSTOMER') }
    it { expect(cookies[0].value).to eq('WILE_E_COYOTE') }
    it { expect(cookies[1].name).to eq('PART_NUMBER') }
    it { expect(cookies[1].value).to eq('ROCKET_LAUNCHER_0001') }
    it { expect(cookies[2]).to eq(nil) }
  end

  context 'Parse request cookie without value (RFC 2965)' do
    context do
      subject (:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=; $Path="/test"') }
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('') }
      it { expect(cookies[1]).to eq(nil) }
    end
    context do
      subject (:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=""; $Path="/test"') }
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('') }
      it { expect(cookies[1]).to eq(nil) }
    end
  end

  context 'Parse quoted request cookie (RFC 2965)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo="b ,a\" r\"\\\\"; $Path="/test"') }
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('b ,a" r"\\') }
    it { expect(cookies[1]).to eq(nil) }
  end

  context 'Parse quoted request cookie roundtrip (RFC 2965)' do
    subject (:cookies1) { Marisa::Cookie::Request.parse('$Version=1; foo="b ,a\";= r\"\\\\"; $Path="/test"') }
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('b ,a";= r"\\') }
    it { expect(cookies1[1]).to eq(nil) }
    it do
      cookies2 = Marisa::Cookie::Request.parse(cookies1[0].to_s)
      expect(cookies2[0].name).to eq('foo')
    end
    it do
      cookies2 = Marisa::Cookie::Request.parse(cookies1[0].to_s)
      expect(cookies2[0].value).to eq('b ,a";= r"\\')
    end
    it do
      cookies2 = Marisa::Cookie::Request.parse(cookies1[0].to_s)
      expect(cookies2[1]).to eq(nil)
    end
  end
end