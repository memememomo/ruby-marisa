
module Marisa
  module Message
    class Request < Marisa::Message::Base
      def initialize(url)
        @url = url
        @cookies = []
      end
    end
  end
end
