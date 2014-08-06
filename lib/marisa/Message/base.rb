module Marisa
  module Message
    class Base
      attr_accessor :cookies

      def initialize
        @cookies = []
      end

      def cookie(name)
        # Cache
        unless @cache
          @cache = {}
          @cookies.each do |cookie|
            @cache[cookie.name] = cookie
          end
        end
        @cache[name]
      end
    end
  end
end