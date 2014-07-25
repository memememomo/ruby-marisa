
module Marisa
  class Cookie
    attr_accessor :name, :value

    def parse(str)
      raise %(Method "parse" not implemented by subclass)
    end

    def to_s
      raise %(Method "to_string" not implemented by subclass)
    end
  end
end
