require 'marisa/cookie'
require 'marisa/util'
require 'marisa/date'

module Marisa
  module Cookie
    class Response < Marisa::Cookie::Base
      attr_accessor :domain, :httponly, :max_age, :origin, :path, :secure

      def initialize(args={})
        super(args)
        self.domain   = args[:domain] || nil
        self.httponly = args[:httponly] || nil
        self.max_age  = args[:max_age] || nil
        self.origin   = args[:origin] || nil
        self.path     = args[:path] || nil
        self.secure   = args[:secure] || nil
      end

      def expires=(val)
        @expires = val.class == 'Marisa::Date' ? val : Marisa::Date.parse(val)
      end

      def expires
        @expires.nil? ? nil : @expires
      end

      def self.parse(str='')
        cookies = []
        tree    = Marisa::Util.split_header(str.to_s)
        while tree.length > 0
          pairs = tree.shift
          i     = 0
          while pairs.length > 0
            name  = pairs.shift
            value = pairs.shift

            # "expires" is a special case, thank you Netscape...
            if /^expires$/i =~ name
              pairs += tree.shift || []
              len   = /-/ =~ (pairs[0] || '') ? 6 : 10
              value += pairs.slice(0, len).select { |n| n != nil }.unshift(',').join(' ')
            end

            # This will only run once
            if i == 0
              i += 1
              cookies << Response.new({:name => name, :value => value})
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
        return '' unless self.name.length
        value  = self.value || ''
        cookie = [name, value =~ /[,;" ]/ ? Marisa::Util.quote(value) : value].join('=')

        # "expires" (Netscape)
        cookie += "; expires=#{self.expires}" if self.expires

        # "domain" (Netscape)
        cookie += "; domain=#{self.domain}" if self.domain

        # "path" (Netscape)
        cookie += "; path=#{self.path}" if self.path

        # "secure" (Netscape)
        cookie += '; secure' if self.secure

        # "Max-Age" (RFC 6265)
        cookie += "; Max-Age=#{self.max_age}" if self.max_age

        # "HttpOnly" (RFC 6265)
        cookie += '; HttpOnly' if self.httponly

        cookie
      end
    end
  end
end