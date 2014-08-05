
module Marisa
  module Cookie
    class Base
      attr_accessor :name, :value

      def initialize(args={})
        self.name = args[:name] || nil
        self.value = args[:value] || nil
      end

      def parse(str)
        raise %(Method "parse" not implemented by subclass)
      end

      def to_s
        raise %(Method "to_string" not implemented by subclass)
      end
    end
  end
end
