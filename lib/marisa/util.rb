module Marisa
  module Util
    def self.quote(str)
      str.gsub!(/(["\\])/) do |text|
        text = '\\' + $1
      end
      %("#{text}")
    end

    def self.split_header(str)
      tree = []
      token = []
      str.gsub!(/^[,;\s]*([^=;, ]+)\s*/) do |text|
        text = ''
        token.push($1)
        token.push(nil)

        token[-1] = unquote if str.sub!(/^=\s*("(?:\\\\|\\"|[^"])*"|[^;, ]*)\s*/, "")

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
