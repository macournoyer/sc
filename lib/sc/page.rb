module Sc
  class Page
    attr_reader :site, :source_filename, :name
    
    def initialize(site, source_filename)
      @site = site
      @source_filename = source_filename
      @name = @source_filename[/^site\/\w+\/(.*)\.\w+$/, 1]
      raise "Bad page: #{@source_filename}" unless @name
    end
    
    def ext
      "html"
    end
    
    def content_type
      "text/html"
    end
    
    def directory
      ::File.dirname(name)
    end
    
    def short_name
      name.split("/").last
    end
    
    def title
      short_name.gsub("_", " ").capitalize
    end
    
    def partial?
      ::File.basename(source_filename)[0] == ?_
    end
    
    def index?
      name =~ /(^|\/)index$/
    end
    
    def compiled_filename
      path = name
      path += "/index" unless index?
      "build/#{path}.#{ext}"
    end
    
    def url
      if index?
        ("/" + name.gsub(/(^|\/)index$/, "/")).squeeze("/")
      else
        "/#{name}"
      end
    end
    
    def template
      Tilt.new(source_filename)
    end
    
    def render
      context = RenderingContext.new(self)
      content = context.render_template(template)
      
      if layout_template = find_template("layouts/#{context.layout}")
        content = context.render_template(layout_template) { content }
      end
      
      if base_layout = find_template("layouts/base")
        content = context.render_template(base_layout) { content }
      end
      
      content
    end
    
    private
      def find_template(name)
        if file = Dir["./site/#{name}.{#{Tilt.mappings.keys * ','}}"].first
          Tilt.new(file)
        end
      end
  end
end