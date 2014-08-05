require 'time'

module Marisa
  module Util
    def self.quote(str)
      str.gsub!(/(["\\])/) { "\\" + $1 }
      %("#{str}")
    end

    def self.split_header(str)
      tree = []
      token = []
      while str.length != 0
        str.sub!(/^[,;\s]*([^=;, ]+)\s*/, '')
        token.push($1)
        token.push(nil)

        if str.sub!(/^=\s*("(?:\\\\|\\"|[^"])*"|[^;, ]*)\s*/, '')
          token[-1] = unquote($1)
        end

        # Separator
        str.sub!(/^;\s*/, '')
        next unless str.sub!(/^,\s*/,'')
        tree.push(token)
        token = []
      end

      # Take care of final token
      if token.length > 0
        tree.push(token)
      end

      tree
    end

    def self.unquote(str)
      return str if str !~ /^"(.*)"$/
      str.gsub!(/^"(.*)"$/, "#{$1}")
      str.gsub!(/\\\\/, "\\")
      str.gsub!(/\\"/, "\"")
      str
    end
  end
end
