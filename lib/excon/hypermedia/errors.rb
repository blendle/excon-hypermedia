# frozen_string_literal: true

# :no-doc:
module Excon
  module HyperMedia
    class Error < StandardError; end

    UnknownRelationError = Class.new(Error)
  end
end
