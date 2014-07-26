require 'marisa/cookie'
require 'marisa/util'

module Marisa
  module Cookie
    class Request < Marisa::Cookie::Base
      def self.parse(str='')
        cookies = []
        pairs = []
        Marisa::Util.split_header(str).each do |s|
          s.each do |s2|
            pairs.push(s2)
          end
        end
        if pairs.length > 0
          pairs.each_slice(2) do |attr|
            name = attr[0]
            value = attr[1]
            next if name =~ /^\$/
            cookies.push(Request.new(name, value))
          end
        end
        cookies
      end

      def to_s
        name = self.name || ''
        return '' unless name.length
        value = self.value || ''
        if value =~ /[,;" ]/
          value = Marisa::Util.quote(value)
        end
        [name,value].join('=')
      end
    end
  end
end
