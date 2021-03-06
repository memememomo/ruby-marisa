require 'rspec'
require 'marisa/cookie/request'
require 'marisa/cookie/response'

describe 'Marisa::Cookie::Request' do

  subject(:req) { Marisa::Cookie::Request.new }

  context 'Request cookie as string' do
    it do
      req.name  = '0'
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
      req.name  = 'foo'
      req.value = ''
      expect(req.to_s).to eq('foo=')
    end
  end

  context 'Empty request cookie' do
    it do
      expect(Marisa::Cookie::Request.parse).to match_array []
    end
  end

  context 'Parse normal request cookie (RFC 2965)' do
    subject(:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=bar; $Path="/test"') }
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('bar') }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse request cookies from multiple header value (RFC 2965)' do
    subject(:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=bar; $Path="/test", $Version=0; baz=yada; $Path="/test"') }
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('bar') }
    it { expect(cookies[1].name).to eq('baz') }
    it { expect(cookies[1].value).to eq('yada') }
    it { expect(cookies[2]).to be_nil }
  end

  context 'Parse request cookie (netscape)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('CUSTOMER=WILE_E_COYOTE') }
    it { expect(cookies[0].name).to eq('CUSTOMER') }
    it { expect(cookies[0].value).to eq('WILE_E_COYOTE') }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse multiple request cookies (Netscape)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('CUSTOMER=WILE_E_COYOTE; PART_NUMBER=ROCKET_LAUNCHER_0001') }
    it { expect(cookies[0].name).to eq('CUSTOMER') }
    it { expect(cookies[0].value).to eq('WILE_E_COYOTE') }
    it { expect(cookies[1].name).to eq('PART_NUMBER') }
    it { expect(cookies[1].value).to eq('ROCKET_LAUNCHER_0001') }
    it { expect(cookies[2]).to be_nil }
  end

  context 'Parse multiple request cookies from multiple header values (Netscape)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('CUSTOMER=WILE_E_COYOTE, PART_NUMBER=ROCKET_LAUNCHER_0001') }
    it { expect(cookies[0].name).to eq('CUSTOMER') }
    it { expect(cookies[0].value).to eq('WILE_E_COYOTE') }
    it { expect(cookies[1].name).to eq('PART_NUMBER') }
    it { expect(cookies[1].value).to eq('ROCKET_LAUNCHER_0001') }
    it { expect(cookies[2]).to be_nil }
  end

  context 'Parse request cookie without value (RFC 2965)' do
    context do
      subject (:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=; $Path="/test"') }
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('') }
      it { expect(cookies[1]).to be_nil }
    end
    context do
      subject (:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=""; $Path="/test"') }
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('') }
      it { expect(cookies[1]).to be_nil }
    end
  end

  context 'Parse quoted request cookie (RFC 2965)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo="b ,a\" r\"\\\\"; $Path="/test"') }
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('b ,a" r"\\') }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse quoted request cookie roundtrip (RFC 2965)' do
    let (:cookies1) { Marisa::Cookie::Request.parse('$Version=1; foo="b ,a\";= r\"\\\\"; $Path="/test"') }
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('b ,a";= r"\\') }
    it { expect(cookies1[1]).to be_nil }
    let (:cookies2) { Marisa::Cookie::Request.parse(cookies1[0].to_s) }
    it { expect(cookies2[0].name).to eq('foo') }
    it { expect(cookies2[0].value).to eq('b ,a";= r"\\') }
    it { expect(cookies2[1]).to be_nil }
  end

  context 'Parse quoted request cookie roundtrip (RFC 2965, alternative)' do
    let (:cookies1) { Marisa::Cookie::Request.parse('$Version=1; foo="b ,a\" r\"\\\\"; $Path="/test"') }
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('b ,a" r"\\') }
    it { expect(cookies1[1]).to be_nil }
    let (:cookies2) { Marisa::Cookie::Request.parse(cookies1[0].to_s) }
    it { expect(cookies2[0].name).to eq('foo') }
    it { expect(cookies2[0].value).to eq('b ,a" r"\\') }
    it { expect(cookies2[1]).to be_nil }
  end

  context 'Parse quoted request cookie roundtrip (RFC 2965, another alternative)' do
    let (:cookies1) { Marisa::Cookie::Request.parse('$Version=1; foo="b ;a\" r\"\\\\"; $Path="/test"') }
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('b ;a" r"\\') }
    it { expect(cookies1[1]).to be_nil }
    let (:cookies2) { Marisa::Cookie::Request.parse(cookies1[0].to_s) }
    it { expect(cookies2[0].name).to eq('foo') }
    it { expect(cookies2[0].value).to eq('b ;a" r"\\') }
    it { expect(cookies2[1]).to be_nil }
  end

  context 'Parse quoted request cookie roundtrip (RFC 2965, yet another alternative)' do
    let (:cookies1) { Marisa::Cookie::Request.parse('$Version=1; foo="\"b a\" r\""; $Path="/test"') }
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('"b a" r"') }
    it { expect(cookies1[1]).to be_nil }
    let (:cookies2) { Marisa::Cookie::Request.parse(cookies1[0].to_s) }
    it { expect(cookies2[0].name).to eq('foo') }
    it { expect(cookies2[0].value).to eq('"b a" r"') }
    it { expect(cookies2[1]).to be_nil }
  end

  context 'Parse multiple cookie request (RFC 2965)' do
    subject (:cookies) { Marisa::Cookie::Request.parse('$Version=1; foo=bar; $Path=/test; baz="la la"; $Path=/test') }
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('bar') }
    it { expect(cookies[1].name).to eq('baz') }
    it { expect(cookies[1].value).to eq('la la') }
    it { expect(cookies[2]).to be_nil }
  end
end

describe 'Marisa::Cookie::Response' do
  context 'Response cookie as string' do
    subject (:cookies) do
      cookies       = Marisa::Cookie::Response.new
      cookies.name  = 'foo'
      cookies.value = 'ba r'
      cookies.path  = '/test'
      cookies
    end
    it { expect(cookies.to_s).to eq('foo="ba r"; path=/test') }
  end

  context 'Response cookie without value as string' do
    it do
      cookies      = Marisa::Cookie::Response.new
      cookies.name = 'foo'
      cookies.path = '/test'
      expect(cookies.to_s).to eq('foo=; path=/test')
    end

    it do
      cookies       = Marisa::Cookie::Response.new
      cookies.name  = 'foo'
      cookies.value = ''
      cookies.path  = '/test'
      expect(cookies.to_s).to eq('foo=; path=/test')
    end
  end

  context 'Full response cookie as string' do
    it do
      cookies          = Marisa::Cookie::Response.new
      cookies.name     = '0'
      cookies.value    = 'ba r'
      cookies.domain   = 'example.com'
      cookies.path     = '/test'
      cookies.max_age  = 60
      cookies.expires  = 1218092879
      cookies.secure   = 1
      cookies.httponly = 1
      expect(cookies.to_s).to eq('0="ba r"; expires=Thu, 07 Aug 2008 07:07:59 GMT; domain=example.com; path=/test; secure; Max-Age=60; HttpOnly')
    end
  end

  context 'Empty response cookie' do
    it { expect(Marisa::Cookie::Response.parse).to match_array [] }
  end

  context 'Parse response cookie (Netscape)' do
    subject(:cookies) do
      cookies = Marisa::Cookie::Response.parse('CUSTOMER=WILE_E_COYOTE; path=/; expires=Tuesday, 09-Nov-1999 23:12:40 GMT')
    end
    it { expect(cookies[0].name).to eq('CUSTOMER') }
    it { expect(cookies[0].value).to eq('WILE_E_COYOTE') }
    it { expect(cookies[0].expires.to_s).to eq('Tue, 09 Nov 1999 23:12:40 GMT') }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse multiple response cookies (Netscape)' do
    subject(:cookies) do
      cookies = Marisa::Cookie::Response.parse(
          'CUSTOMER=WILE_E_COYOTE; expires=Tuesday, 09-Nov-1999 23:12:40 GMT; path=/,SHIPPING=FEDEX; path=/; expires=Tuesday, 09-Nov-1999 23:12:41 GMT'
      )
    end
    it { expect(cookies[0].name).to eq('CUSTOMER') }
    it { expect(cookies[0].value).to eq('WILE_E_COYOTE') }
    it { expect(cookies[0].expires.to_s).to eq('Tue, 09 Nov 1999 23:12:40 GMT') }
    it { expect(cookies[1].name).to eq('SHIPPING') }
    it { expect(cookies[1].value).to eq('FEDEX') }
    it { expect(cookies[1].expires.to_s).to eq('Tue, 09 Nov 1999 23:12:41 GMT') }
    it { expect(cookies[2]).to be_nil }
  end

  context 'Parse response cookie (RFC 6265)' do
    subject (:cookies) do
      cookies = Marisa::Cookie::Response.parse(
          'foo="ba r"; Domain=example.com; Path=/test; Max-Age=60; Expires=Thu, 07 Aug 2008 07:07:59 GMT; Secure;'
      )
    end
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('ba r') }
    it { expect(cookies[0].domain).to eq('example.com') }
    it { expect(cookies[0].path).to eq('/test') }
    it { expect(cookies[0].max_age).to eq('60') }
    it { expect(cookies[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies[0].secure).to eq(1) }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse response cookie with invalid flag (RFC 6265)' do
    subject (:cookies) do
      cookies = Marisa::Cookie::Response.parse(
          'foo="ba r"; Domain=example.com; Path=/test; Max-Age=60; Expires=Thu, 07 Aug 2008 07:07:59 GMT; InSecure;'
      )
    end
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('ba r') }
    it { expect(cookies[0].domain).to eq('example.com') }
    it { expect(cookies[0].path).to eq('/test') }
    it { expect(cookies[0].max_age).to eq('60') }
    it { expect(cookies[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies[0].secure).to be_nil }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse quoted response cookie (RFC 6265)' do
    subject (:cookies) do
      cookies = Marisa::Cookie::Response.parse(
          'foo="b a\" r\"\\\\"; Domain=example.com; Path=/test; Max-Age=60; Expires=Thu, 07 Aug 2008 07:07:59 GMT; Secure'
      )
    end
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('b a" r"\\') }
    it { expect(cookies[0].domain).to eq('example.com') }
    it { expect(cookies[0].path).to eq('/test') }
    it { expect(cookies[0].max_age).to eq('60') }
    it { expect(cookies[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies[0].secure).to eq(1) }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse quoted response cookie (RFC 6265, alternative)' do
    subject (:cookies) do
      Marisa::Cookie::Response.parse(
          'foo="b a\" ;r\"\\\\"; domain=example.com; path=/test; Max-Age=60; expires=Thu, 07 Aug 2008 07:07:59 GMT; secure'
      )
    end
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('b a" ;r"\\') }
    it { expect(cookies[0].domain).to eq('example.com') }
    it { expect(cookies[0].path).to eq('/test') }
    it { expect(cookies[0].max_age).to eq('60') }
    it { expect(cookies[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies[0].secure).to eq(1) }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse quoted response cookie roundtrip (RFC 6265)' do
    let (:cookies1) do
      Marisa::Cookie::Response.parse(
          'foo="b ,a\";= r\"\\\\"; Domain=example.com; Path=/test; Max-Age=60; Expires=Thu, 07 Aug 2008 07:07:59 GMT; Secure'
      )
    end
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('b ,a";= r"\\') }
    it { expect(cookies1[0].domain).to eq('example.com') }
    it { expect(cookies1[0].path).to eq('/test') }
    it { expect(cookies1[0].max_age).to eq('60') }
    it { expect(cookies1[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies1[0].secure).to eq(1) }
    it { expect(cookies1[1]).to be_nil }
    let (:cookies2) { Marisa::Cookie::Response.parse(cookies1[0]) }
    it { expect(cookies2[0].name).to eq('foo') }
    it { expect(cookies2[0].value).to eq('b ,a";= r"\\') }
    it { expect(cookies2[0].domain).to eq('example.com') }
    it { expect(cookies2[0].path).to eq('/test') }
    it { expect(cookies2[0].max_age).to eq('60') }
    it { expect(cookies2[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies2[0].secure).to eq(1) }
    it { expect(cookies2[1]).to be_nil }
  end

  context 'Parse quoted response cookie roundtrip (RFC 6265, alternative)' do
    let (:cookies1) do
      Marisa::Cookie::Response.parse(
          'foo="b ,a\" r\"\\\\"; Domain=example.com; Path=/test; Max-Age=60; Expires=Thu, 07 Aug 2008 07:07:59 GMT; Secure'
      )
    end
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('b ,a" r"\\') }
    it { expect(cookies1[0].domain).to eq('example.com') }
    it { expect(cookies1[0].path).to eq('/test') }
    it { expect(cookies1[0].max_age).to eq('60') }
    it { expect(cookies1[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies1[0].secure).to eq(1) }
    it { expect(cookies1[1]).to be_nil }
    let (:cookies2) { Marisa::Cookie::Response.parse(cookies1[0]) }
    it { expect(cookies2[0].name).to eq('foo') }
    it { expect(cookies2[0].value).to eq('b ,a" r"\\') }
    it { expect(cookies2[0].domain).to eq('example.com') }
    it { expect(cookies2[0].path).to eq('/test') }
    it { expect(cookies2[0].max_age).to eq('60') }
    it { expect(cookies2[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies2[0].secure).to eq(1) }
    it { expect(cookies2[1]).to be_nil }
  end

  context 'Parse quoted response cookie roundtrip (RFC 6265, another alternative)' do
    let (:cookies1) do
      Marisa::Cookie::Response.parse(
          'foo="b ;a\" r\"\\\\"; Domain=example.com; Path=/test; Max-Age=60; Expires=Thu, 07 Aug 2008 07:07:59 GMT;  Secure'
      )
    end
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('b ;a" r"\\') }
    it { expect(cookies1[0].domain).to eq('example.com') }
    it { expect(cookies1[0].path).to eq('/test') }
    it { expect(cookies1[0].max_age).to eq('60') }
    it { expect(cookies1[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies1[0].secure).to eq(1) }
    it { expect(cookies1[1]).to be_nil }
    let (:cookies2) { Marisa::Cookie::Response.parse(cookies1[0]) }
    it { expect(cookies2[0].name).to eq('foo') }
    it { expect(cookies2[0].value).to eq('b ;a" r"\\') }
    it { expect(cookies2[0].domain).to eq('example.com') }
    it { expect(cookies2[0].path).to eq('/test') }
    it { expect(cookies2[0].max_age).to eq('60') }
    it { expect(cookies2[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies2[0].secure).to eq(1) }
    it { expect(cookies2[1]).to be_nil }
  end

  context 'Parse quoted response cookie roundtrip (RFC 6265, yet another alternative)' do
    let (:cookies1) do
      Marisa::Cookie::Response.parse(
          'foo="\"b a\" r\""; Domain=example.com; Path=/test; Max-Age=60; Expires=Thu, 07 Aug 2008 07:07:59 GMT; Secure'
      )
    end
    let (:cookies2) { Marisa::Cookie::Response.parse(cookies1[0]) }
    it { expect(cookies1[0].name).to eq('foo') }
    it { expect(cookies1[0].value).to eq('"b a" r"') }
    it { expect(cookies1[0].domain).to eq('example.com') }
    it { expect(cookies1[0].path).to eq('/test') }
    it { expect(cookies1[0].max_age).to eq('60') }
    it { expect(cookies1[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies1[0].secure).to eq(1) }
    it { expect(cookies1[1]).to be_nil }
    it { expect(cookies2[0].name).to eq('foo') }
    it { expect(cookies2[0].value).to eq('"b a" r"') }
    it { expect(cookies2[0].domain).to eq('example.com') }
    it { expect(cookies2[0].path).to eq('/test') }
    it { expect(cookies2[0].max_age).to eq('60') }
    it { expect(cookies2[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
    it { expect(cookies2[0].secure).to eq(1) }
    it { expect(cookies2[1]).to be_nil }
  end

  context 'Parse response cookie without value (RFC 2965)' do
    context do
      subject (:cookies) do
        Marisa::Cookie::Response.parse(
            'foo=""; Version=1; Domain=example.com; Path=/test; Max-Age=60; expires=Thu, 07 Aug 2008 07:07:59 GMT; Secure'
        )
      end
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('') }
      it { expect(cookies[0].domain).to eq('example.com') }
      it { expect(cookies[0].path).to eq('/test') }
      it { expect(cookies[0].max_age).to eq('60') }
      it { expect(cookies[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
      it { expect(cookies[0].secure).to eq(1) }
      it { expect(cookies[0].to_s).to eq('foo=; expires=Thu, 07 Aug 2008 07:07:59 GMT; domain=example.com; path=/test; secure; Max-Age=60') }
      it { expect(cookies[1]).to be_nil }
    end
    context do
      subject (:cookies) do
        Marisa::Cookie::Response.parse(
            'foo=; Version=1; Domain=example.com; Path=/test; Max-Age=60; expires=Thu, 07 Aug 2008 07:07:59 GMT; Secure'
        )
      end
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('') }
      it { expect(cookies[0].domain).to eq('example.com') }
      it { expect(cookies[0].path).to eq('/test') }
      it { expect(cookies[0].max_age).to eq('60') }
      it { expect(cookies[0].expires.to_s).to eq('Thu, 07 Aug 2008 07:07:59 GMT') }
      it { expect(cookies[0].secure).to eq(1) }
      it { expect(cookies[0].to_s).to eq('foo=; expires=Thu, 07 Aug 2008 07:07:59 GMT; domain=example.com; path=/test; secure; Max-Age=60') }
      it { expect(cookies[1]).to be_nil }
    end
  end

  context 'Parse response cookie with broken Expires value' do
    context do
      subject (:cookies) { Marisa::Cookie::Response.parse('foo="ba r"; Expires=Th') }
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('ba r') }
      it { expect(cookies[1]).to be_nil }
    end
    context do
      subject (:cookies) { Marisa::Cookie::Response.parse('foo="ba r"; Expires=Th; Path=/test') }
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('ba r') }
      it { expect(cookies[1]).to be_nil }
    end
  end

  context 'Response cookie with Max-Age 0 and Expires 0' do
    it do
      cookie         = Marisa::Cookie::Response.new
      cookie.name    = 'foo'
      cookie.value   = 'bar'
      cookie.path    = '/'
      cookie.max_age = 0
      cookie.expires = 0
      expect(cookie.to_s).to eq('foo=bar; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; Max-Age=0')
    end
  end

  context 'Parse response cookie with Max-Age 0 and Expires 0 (RFC 6265)' do
    subject (:cookies) do
      Marisa::Cookie::Response.parse(
          'foo=bar; Domain=example.com; Path=/; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Secure'
      )
    end
    it { expect(cookies[0].name).to eq('foo') }
    it { expect(cookies[0].value).to eq('bar') }
    it { expect(cookies[0].domain).to eq('example.com') }
    it { expect(cookies[0].path).to eq('/') }
    it { expect(cookies[0].max_age).to eq('0') }
    it { expect(cookies[0].expires.to_s).to eq('Thu, 01 Jan 1970 00:00:00 GMT') }
    it { expect(cookies[0].secure).to eq(1) }
    it { expect(cookies[1]).to be_nil }
  end

  context 'Parse response cookie with two digit year (RFC 6265)' do
    context do
      subject (:cookies) do
        Marisa::Cookie::Response.parse(
            'foo=bar; Path=/; Expires=Saturday, 09-Nov-19 23:12:40 GMT; Secure'
        )
      end
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('bar') }
      it { expect(cookies[0].path).to eq('/') }
      it { expect(cookies[0].expires.to_s).to eq('Sat, 09 Nov 2019 23:12:40 GMT') }
      it { expect(cookies[0].secure).to eq(1) }
      it { expect(cookies[1]).to be_nil }
    end
    context do
      subject (:cookies) do
        Marisa::Cookie::Response.parse(
            'foo=bar; Path=/; Expires=Tuesday, 09-Nov-99 23:12:40 GMT; Secure'
        )
      end
      it { expect(cookies[0].name).to eq('foo') }
      it { expect(cookies[0].value).to eq('bar') }
      it { expect(cookies[0].path).to eq('/') }
      it { expect(cookies[0].expires.to_s).to eq('Tue, 09 Nov 1999 23:12:40 GMT') }
      it { expect(cookies[0].secure).to eq(1) }
      it { expect(cookies[1]).to be_nil }
    end
  end

end