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
          Marisa::Cookie::Response.new({
              :domain => 'example.com',
              :path   => '/foo',
              :name   => 'foo',
              :value  => 'bar',
          }),
          Marisa::Cookie::Response.new({
              :domain => 'example.com',
              :path   => '/',
              :name   => 'just',
              :value  => 'works',
          })
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
end