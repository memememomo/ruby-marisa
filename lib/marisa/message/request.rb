require 'marisa/message/base'

module Marisa
  module Message
    class Request < Marisa::Message::Base
      attr_accessor :url

      def url=(url)
        if url.class == 'URI'
          @url = url
        else
          @url = URI.parse(url)
        end
      end
    end
  end
end
