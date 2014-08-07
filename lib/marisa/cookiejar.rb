require 'uri'
require 'marisa/cookie/request'

module Marisa
  class CookieJar

    attr_accessor :max_cookie_size

    def initialize
      @max_cookie_size = 4096
      @jar             = {}
    end

    # @param [Array<Marisa::Cookie::Request>] cookies
    # @return [Marisa::CookieJar]
    def add(*cookies)
      size = @max_cookie_size

      cookies.each do |cookie|
        # Convert max age to expires
        if cookie.max_age
          cookie.expires = cookie.max_age.to_i + Time.now.to_i
        end

        # Check cookie size
        next if (cookie.value || '').length > size

        # Replace cookie
        cookie.origin ||= ''
        domain        = (cookie.domain || cookie.origin).downcase

        next if domain.length <= 0
        domain.sub!(/^\./, '')

        cookie.path ||= ''
        next if cookie.path.length <= 0

        cookie.name ||= ''
        next if cookie.name.length <= 0

        @jar[domain.to_s] ||= []
        @jar[domain.to_s] =
            @jar[domain.to_s].select { |j| self._compare(j, cookie.path, cookie.name, cookie.origin) }.push(cookie)
      end

      self
    end

    def all
      @jar.keys.sort.map { |k| @jar[k] }.flatten
    end

    def empty
      @jar = {}
    end

    # @param [Marisa::Request] req
    # @param [Marisa::Response] res
    def extract(tx)
      url = tx.req.url
      tx.res.cookies.each do |cookie|
        # Validate domain
        host          = url.host
        cookie.origin = host
        domain        = (cookie.domain || cookie.origin).downcase
        domain.sub!(/^\./, '')
        next if host != domain && (/#{Regexp.escape(domain)}$/ !~ host || /\.\d+$/ =~ host)

        # Validate path
        path        = cookie.path || File.dirname(url.path)
        cookie.path ||= path
        # $path = Mojo::Path->new($path)->trailing_slash(0)->to_abs_string;
        next unless self._path(path, url.path)
        cookie.path = path
        self.add(cookie)
      end
    end

    # @param [URI] url
    def find(url)
      return unless url.clone.host
      domain = url.host.clone
      host   = url.host.clone
      path   = url.path
      found  = []
      while domain =~ /[^.]+\.[^.]+|localhost$/
        d = domain.clone.to_s
        domain.gsub!(/^[^\.]+\.?/, '')

        next unless old = @jar[d]
        # Grab cookies
        new = @jar[d] = []
        old.each do |cookie|
          next if cookie.domain.nil? && host != cookie.origin

          # Check if cookie has expired
          expires = cookie.expires
          next if expires && Time.now.to_i > (expires.to_i || 0)
          new << cookie

          # Taste cookie
          next if cookie.secure && url.scheme != 'https'
          next unless self._path(cookie.path, path)
          name  = cookie.name
          value = cookie.value
          found << Marisa::Cookie::Request.new({:name => name, :value => value})
        end
      end
      found
    end

    def inject(tx)
      return unless @jar.keys.length > 0
      tx.req.cookies += self.find(tx.req.url)
    end

    def _compare(cookie, path, name, origin)
      return true if cookie.path != path || cookie.name != name
      (cookie.origin || '') != origin
    end

    def _path(arg1, arg2)
      arg1 == '/' || arg1 == arg2 || arg2 =~ /^#{Regexp.quote(arg1)}\//
    end
  end
end