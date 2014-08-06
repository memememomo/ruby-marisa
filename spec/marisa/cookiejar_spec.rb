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
end