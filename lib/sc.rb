require 'tilt'
require 'compass'

require "sc/helpers"
require "sc/rendering"
require "sc/templates"
require "sc/site"
require "sc/compiler"

module Sc
  def self.site
    @site ||= Site.new
  end
  
  def self.compile
    Compiler.new.compile(site)
  end
  
  def self.call(env)
    site.call(env)
  end
end
