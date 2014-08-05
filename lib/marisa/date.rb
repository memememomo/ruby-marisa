require 'time'

module Marisa
  class Date < Time
    def self.parse(date)
      # epoch (784111777)
      return self.at(date.to_i) if /^\d+$/ =~ date.to_s

      begin
        return super(date)
      rescue
        return Marisa::Date.new
      end
    end

    def to_s
      self.httpdate
    end
  end
end
