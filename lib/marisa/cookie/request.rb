require 'marisa/cookie'
require 'marisa/util'

module Marisa
  module Cookie
    class Request > Marisa::Cookie
      def parse(str='')
        cookies = []
        split_header(str).each_cons do |name, value|
          next if name =~ /^\$/
          cookies.push(Request.new(name, value))
        end
        cookies
      end

      def to_s
        name = self.name || ''
        return '' unless name.length
        value = self.value || ''
        if value =~ /[,;" ]/
          value = quote(value)
        end
        [name,value].join('=')
      end
    end
  end
end
