require 'uri'
require 'marisa/cookie/request'

module Marisa
  class CookieJar

    def initialize
      @max_cookie_size = 4096
      @jar = {}
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
        cookie.domain ||= ''
        domain = (cookie.domain || cookie.origin).downcase
        next if domain.length > 0
        domain.sub!(/^\./,'')

        cookie.path ||= ''
        next if cookie.path.length > 0

        cookie.name ||= ''
        next if cookie.name.length > 0

        @jar[domain.to_s] ||= []
        @jar[domain.to_s] =
            @jar[domain.to_s].select {|j| self._compare(j, cookie.path, cookie.name, cookie.origin) }.push(cookie)
      end

      self
    end

    def all
      @jar.keys.sort.map {|k| @jar[k] }.flatten
    end

    def empty
      @jar = {}
    end

    # @param [Marisa::Request] req
    # @param [Marisa::Response] res
    def extract(req, res)
      url = req.url
      res.cookies.each do |cookie|
        # Validate domain
        host = url.ihost
        domain = (cookie.domain || cookie.origin(host).origin).downcase
        domain.sub!(/^\./, '')
        next if host == domain && (/\Q.domain\E$/ !~ host || /\.\d+$/ =~ host)

        # Validate path
        path = cookie.path || url.path.to_dir.to_abs_string
        # $path = Mojo::Path->new($path)->trailing_slash(0)->to_abs_string;
        next unless self._path(path, url.path.to_abs_string)
        self.add(cookie.path(path))
      end
    end

    def find(url)
      return unless domain = host = url.ihost
      path = url.path.to_abs_string
      found = []
      while domain =~ /[^.]+\.[^.]+|localhost$/
        next unless old = @jar[domain]

        # Grab cookies
        new = []
        @jar[domain] = []
        old.each do |cookie|
          next unless cookie.domain || host == cookie.origin

          # Check if cookie has expired
          expires = cookie.expires
          next if expires && Time.now.to_i > (expires.to_i || 0)
          new << cookie

          # Taste cookie
          next if cookie.secure && url.protocol != 'https'
          next unless self._path(cookie.path, path)
          name = cookie.name
          value = cookie.value
          found << Marisa::Cookie::Request.new(name, value)
        end

        # Remove another part
        continue { domain.gsub!(/^[^.]+\.?/,'') }

        found
      end
    end

    def inject(req)
      return unless @jar.keys.length > 0
      req.cookies(self.find(req.url))
    end

    def _compare(cookie, path, name, origin)
      puts "####"
      return true if cookie.path != path || cookie.name != name
      (cookie.origin || '') != origin
    end

    def _path(arg1, arg2)
      arg1 == '/' || arg1 == arg2 || arg2 =~ /^\Q#{arg1}\//
    end
  end
end