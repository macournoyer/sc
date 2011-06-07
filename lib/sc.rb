require 'tilt'
require 'compass'

require "sc/templates"
require "sc/helpers"
require "sc/rendering"
require "sc/page"
require "sc/asset"
require "sc/site"

module Sc
  def self.site
    @site ||= Site.new
  end
  
  def self.compile
    site.compile
  end
  
  def self.call(env)
    site.call(env)
  end
end
