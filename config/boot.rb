ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'bigdecimal'
unless BigDecimal.respond_to?(:new)
  def BigDecimal.new(*args)
    BigDecimal(*args)
  end
end

require 'nokogiri'
module Nokogiri
  HTML4 = HTML unless defined?(HTML4)
end
