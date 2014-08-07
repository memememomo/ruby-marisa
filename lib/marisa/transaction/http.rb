require 'marisa/message/request'
require 'marisa/message/response'

module Marisa
  module Transaction
    class Http
      attr_accessor :req, :res

      def initialize
        @req = Marisa::Message::Request.new
        @res = Marisa::Message::Response.new
      end
    end
  end
end

