require 'rspec'
require 'marisa/cookiejar'
require 'marisa/cookie/request'
require 'marisa/cookie/response'

describe 'Missing values' do
  it do
    jar = Marisa::CookieJar.new
    jar.add(Marisa::Cookie::Response.new({:domain => 'example.com'}))
    jar.add(Marisa::Cookie::Response.new({:name => 'foo'}))
    jar.add(Marisa::Cookie::Response.new({:name => 'foo', :domain => 'example.com'}))
    jar.add(Marisa::Cookie::Response.new({:domain => 'example.com', :path => '/'}))
    expect(jar.all).to match_array []
  end
end