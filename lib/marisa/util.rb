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

    def self.parse_date(date)

      date = date.to_s

      # epoch (784111777)
      return Time.at(date.to_i) if /^\d+$/ =~ date

      months = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
      months_map = []
      [0..11].each do |m|
        months_map[months[m]] = m
      end

      # RFC 822/1123 (Sun, 06 Nov 1994 08:49:37 GMT)
      if /^\w+, \s+(\d+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+GMT$/ =~ date
        day, month, year, h, m, s = $1, months_map[$2], $3, $4, $5, $6
      # RFC 850/1036 (Sunday, 06-Nov-94 08:49:37 GMT)
      elsif /^\w+, \s+(\d+)-(\w+)-(\d+)\s+(\d+):(\d+):(\d+)\s+GMT$/ =~ date
        day, month, year, h, m, s = $1, months_map[$2], $3, $4, $5, $6
      # ANSI C asctime() (Sun Nov    6 08:49:37 1994)
      elsif /^\w+\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)$/ =~ date
        month, day, h, m, s, year = months_map[$1], $2, $3, $4, $5, $6
      # Invalid
      else
        return Time.new
      end

      Time.new(year, month, day, h, m, s)
    end
  end
end
