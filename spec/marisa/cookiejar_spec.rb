require 'rspec'
require 'marisa/cookiejar'
require 'marisa/cookie/request'
require 'marisa/cookie/response'
require 'uri'

describe Marisa::CookieJar do
  subject (:jar) { Marisa::CookieJar.new }
  context 'Missing values' do
    it do
      jar.add(Marisa::Cookie::Response.new({:domain => 'example.com'}))
      jar.add(Marisa::Cookie::Response.new({:name => 'foo'}))
      jar.add(Marisa::Cookie::Response.new({:name => 'foo', :domain => 'example.com'}))
      jar.add(Marisa::Cookie::Response.new({:domain => 'example.com', :path => '/'}))
      expect(jar.all).to match_array []
    end
  end

  context 'Session cookie' do
    it do
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'bar',
              }
          ),
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/',
                  :name   => 'just',
                  :value  => 'works',
              }
          )
      )
      5.times do
        cookies = jar.find(URI.parse('http://example.com/foo'))
        expect(cookies[0].name).to eq('foo')
        expect(cookies[0].value).to eq('bar')
        expect(cookies[1].name).to eq('just')
        expect(cookies[1].value).to eq('works')
        expect(cookies[2]).to be_nil
      end

      jar.empty
      cookies = jar.find(URI.parse('http://example.com/foo'))
      expect(cookies[0]).to be_nil
    end
  end

  context 'localhost' do
    it do
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'localhost',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'bar',
              }
          ),
          Marisa::Cookie::Response.new(
              {
                  :domain => 'foo.localhost',
                  :path   => '/foo',
                  :name   => 'bar',
                  :value  => 'baz',
              }
          )
      )

      cookies = jar.find(URI.parse('http://localhost/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1]).to be_nil

      cookies = jar.find(URI.parse('http://foo.localhost/foo'))
      expect(cookies[0].name).to eq('bar')
      expect(cookies[0].value).to eq('baz')
      expect(cookies[1].name).to eq('foo')
      expect(cookies[1].value).to eq('bar')
      expect(cookies[2]).to be_nil

      cookies = jar.find(URI.parse('http://foo.bar.localhost/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1]).to be_nil

      cookies = jar.find(URI.parse('http://bar.foo.localhost/foo'))
      expect(cookies[0].name).to eq('bar')
      expect(cookies[0].value).to eq('baz')
      expect(cookies[1].name).to eq('foo')
      expect(cookies[1].value).to eq('bar')
      expect(cookies[2]).to be_nil
    end
  end

  # TODO: IDNA
  context 'Random top-level domain and IDNA' do
    it do
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'com',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'bar',
              }
          ),
          Marisa::Cookie::Response.new(
              {
                  :domain => 'xn--bcher-kva.com',
                  :path   => '/foo',
                  :name   => 'bar',
                  :value  => 'baz',
              }
          )
      )

      cookies = jar.find(URI.parse('http://bücher.com/foo'))
      expect(cookies[0].name).to eq('bar')
      expect(cookies[0].value).to eq('baz')
      expect(cookies[1]).to be_nil

      cookies = jar.find(URI.parse('http://bücher.com/foo'))
      expect(cookies[0].name).to eq('bar')
      expect(cookies[0].value).to eq('baz')
      expect(cookies[1]).to be_nil

      cookies = jar.all
      expect(cookies[0].domain).to eq('com')
      expect(cookies[0].path).to eq('/foo')
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1].domain).to eq('xn--bcher-kva.com')
      expect(cookies[1].path).to eq('/foo')
      expect(cookies[1].name).to eq('bar')
      expect(cookies[1].value).to eq('baz')
      expect(cookies[2]).to be_nil
    end
  end

  context 'Huge cookie' do
    it do
      jar.max_cookie_size = 1024
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'small',
                  :value  => 'x',
              }
          ),
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'big',
                  :value  => 'x' * 1024,
              }
          ),
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'huge',
                  :value  => 'x' * 1025,
              }
          )
      )
      cookies = jar.find(URI.parse('http://example.com/foo'))
      expect(cookies[0].name).to eq('small')
      expect(cookies[0].value).to eq('x')
      expect(cookies[1].name).to eq('big')
      expect(cookies[1].value).to eq('x' * 1024)
      expect(cookies[2]).to be_nil
    end
  end

  context 'Expired cookies' do
    it do
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'bar',
              }
          ),
          Marisa::Cookie::Response.new(
              {
                  :domain  => 'labs.example.com',
                  :path    => '/',
                  :name    => 'baz',
                  :value   => '24',
                  :max_age => -1,
              }
          )
      )

      expired         = Marisa::Cookie::Response.new(
          {
              :domain => 'labs.example.com',
              :path   => '/',
              :name   => 'baz',
              :value  => '23',
          }
      )
      expired.expires = Time.now.to_i - 1
      jar.add(expired)

      cookies = jar.find(URI.parse('http://labs.example.com/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1]).to be_nil
    end
  end

  context 'Replace cookie' do
    it do
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'bar1',
              }
          ),
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'bar2',
              }
          )
      )
      cookies = jar.find(URI.parse('http://example.com/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar2')
      expect(cookies[1]).to be_nil
    end
  end

  context 'Switch between secure and normal cookies' do
    it do
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'foo',
                  :secure => 1,
              }
          )
      )
      cookies = jar.find(URI.parse('https://example.com/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('foo')
      cookies = jar.find(URI.parse('http://example.com/foo'))
      expect(cookies.length).to eq(0)

      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'bar',
              }
          )
      )
      cookies = jar.find(URI.parse('http://example.com/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      cookies = jar.find(URI.parse('https://example.com/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1]).to be_nil
    end
  end
  context 'Ignore leading dot' do
    it do
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => '.example.com',
                  :path   => '/foo',
                  :name   => 'foo',
                  :value  => 'bar',
              }
          ),
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo',
                  :name   => 'bar',
                  :value  => 'baz',
              }
          )
      )
      cookies = jar.find(URI.parse('http://www.labs.example.com/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1].name).to eq('bar')
      expect(cookies[1].value).to eq('baz')
      expect(cookies[2]).to be_nil

      cookies = jar.find(URI.parse('http://labs.example.com/foo'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1].name).to eq('bar')
      expect(cookies[1].value).to eq('baz')
      expect(cookies[2]).to be_nil

      cookies = jar.find(URI.parse('http://example.com/foo/bar'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1].name).to eq('bar')
      expect(cookies[1].value).to eq('baz')
      expect(cookies[2]).to be_nil

      cookies = jar.find(URI.parse('http://example.com/foobar'))
      expect(cookies[0]).to be_nil
    end
  end

  context '"(" in path' do
    it do
      jar.add(
          Marisa::Cookie::Response.new(
              {
                  :domain => 'example.com',
                  :path   => '/foo(bar',
                  :name   => 'foo',
                  :value  => 'bar',
              }
          )
      )

      cookies = jar.find(URI.parse('http://example.com/foo(bar'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1]).to be_nil

      cookies = jar.find(URI.parse('http://example.com/foo(bar/baz'))
      expect(cookies[0].name).to eq('foo')
      expect(cookies[0].value).to eq('bar')
      expect(cookies[1]).to be_nil
    end
  end
end