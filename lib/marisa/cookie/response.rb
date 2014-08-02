require 'marisa/cookie'
require 'marisa/util'

module Marisa
  module Cookie
    class Response < Marisa::Cookie::Base
      attr_accessor :domain, :httponly, :max_age, :origin, :path, :secure

      def expires=(val)
        @expires = val.class == 'Time' ? val : Marisa::Util.parse_date(val)
      end

      def expires
        @expires.httpdate
      end

      def self.parse(str='')
        cookies = []
        tree = Marisa::Util.split_header(str.to_s)
        while tree.length > 0
          pairs = tree.shift
          i = 0
          while pairs.length > 0
            name = pairs.shift
            value = pairs.shift

            # "expires" is a special case, thank you Netscape...
            if /^expires$/i =~ name
              pairs += tree.shift || []
              len = /-/ =~ (pairs[0] || '') ? 6 : 10
              value += pairs.slice(0, len).select {|n| n != nil }.unshift(',').join(' ')
            end

            # This will only run once
            if i == 0
              i += 1
              cookies << Response.new(name, value)
              next
            end

            # Attributes (Netscape and RFC 6265)
            next if /^(expires|domain|path|secure|max-age|httponly)$/i !~ name
            attr = $1.downcase
            attr = 'max_age' if attr == 'max-age'
            cookies[-1].__send__(attr+'=', (attr == 'secure' || attr == 'httponly' ? 1 : value))
          end
        end

        cookies
      end

      def to_s
        # Name and value (Netscape)
        return '' unless @name.length
        value = @value || ''
        cookie = [name, value =~ /[,;" ]/ ? Marisa::Util.quote(value) : value].join('=')

        # "expires" (Netscape)
        cookie += "; expires=#{@expires.httpdate}" if @expires

        # "domain" (Netscape)
        cookie += "; domain=#{@domain}" if @domain

        # "path" (Netscape)
        cookie += "; path=#{@path}" if @path

        # "secure" (Netscape)
        cookie += '; secure' if @secure

        # "Max-Age" (RFC 6265)
        cookie += "; Max-Age=#{@max_age}" if @max_age

        # "HttpOnly" (RFC 6265)
        cookie += '; HttpOnly' if @httponly

        cookie
      end
    end
  end
end