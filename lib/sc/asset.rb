module Sc
  class Asset < Page
    attr_reader :type
    
    def initialize(*)
      super
      if source_filename.match(/^site\/assets\/(\w+)\/(.*)\.\w+$/)
        @type = $1
        @name = $2
      else
        raise "Bad asset: #{@source_filename}"
      end
    end
    
    def ext
      case type
      when "javascripts" then "js"
      when "stylesheets" then "css"
      end
    end
    
    def content_type
      case type
      when "stylesheets" then "text/css"
      when "javascripts" then "text/javascript"
      end
    end
    
    def compiled_filename
      "build/#{type}/#{name}.#{ext}"
    end
    
    def url
      "/#{type}/#{name}.#{ext}"
    end
    
    def render
      RenderingContext.new(self).render_template(template)
    end
  end
end