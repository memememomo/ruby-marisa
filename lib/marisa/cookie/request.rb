require 'marisa/cookie'
require 'marisa/util'

module Marisa
  module Cookie
    class Request < Marisa::Cookie::Base
      def self.parse(str='')
        cookies = []
        pairs   = []
        Marisa::Util.split_header(str).each do |s|
          s.each do |s2|
            pairs.push(s2)
          end
        end
        if pairs.length > 0
          pairs.each_slice(2) do |attr|
            n = attr[0]
            v = attr[1]
            next if n =~ /^\$/
            cookies.push(Request.new({:name => n, :value => v}))
          end
        end
        cookies
      end

      def to_s
        n = self.name || ''
        return '' unless n.length
        v = self.value || ''
        if v =~ /[,;" ]/
          v = Marisa::Util.quote(v)
        end
        [n, v].join('=')
      end
    end
  end
end
