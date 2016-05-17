# frozen_string_literal: true
require 'excon'
require 'excon/addressable'
require 'excon/hypermedia/hyper_media'

# :nodoc:
module Excon
  # HyperMedia addition to Excon.
  #
  module Hypermedia
    def new(url, params = {})
      params[:hypermedia] ? super.extend(HyperMedia) : super
    end
  end

  singleton_class.prepend Hypermedia
end
