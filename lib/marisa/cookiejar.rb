require 'uri'
require 'marisa/cookie/request'

module Marisa
  class CookieJar
    @max_cookie_size = 4096
    @jar = {}

    # @param [Array<Marisa::Cookie::Request>] cookies
    def add(cookies=[])
      size = @max_cookie_size

      cookies.each do |cookie|
        # Convert max age to expires
        if cookie.max_age
          cookie.expires = cookie.max_age + Time.now
        end

        # Check cookie size
        next if cookie.value.length > size

        # Replace cookie
        origin = cookie.origin || ''
        domain = (cookie.domain || origin).downcase
        next unless domain
        domain.sub(/^\./,'')
        path = cookie.path
        next unless path
        name = cookie.name || ''
        next unless name.length
        jar = @jar[domain] ||= []
        @jar[domain] = jar.select {|j| self._compare(j, path, name, origin) }.push(cookie)
      end

      self
    end

    def all
      @jar.keys.sort.map {|k| @jar[k] }
    end

    def empty
      @jar = {}
    end

    # @param [Net::HTTP::Request] req
    # @param [Net::HTTP::Response] res
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
          next if expires && time > (expires.epoch || 0)
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

    def inject(req, res)
      return unless @jar.keys.length > 0
      req.cookies(self.find(req.url))
    end

    def _compare(cookie, path, name, origin)
      return 1 if cookie.path != path || cookie.name != name
      (cookie.origin || '') != origin
    end

    def _path(arg1, arg2)
      arg1 == '/' || arg1 == arg2 || arg2 =~ /^\Q#{arg1}\//
    end
  end
end