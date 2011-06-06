module Sc
  module Rendering
    def render(path)
      case File.extname(path)
      when ".css", ".js"
        render_asset path
      else
        render_page path
      end
    end
    
    def render_asset(path)
      if template = find_template(path)
        template.render
      end
    end
    
    def render_page(path)
      path = "index" if path == "/"
      template = find_template("pages/#{path}")
      context = RenderingContext.new
      content = template.render(context)
      
      if layout_template = find_template("layouts/#{context.layout}")
        content = layout_template.render(context) { content }
      end
      
      if base_layout = find_template("layouts/base")
        content = base_layout.render(context) { content }
      end
      
      content
    end
    
    private
      def find_template(path)
        path = path.gsub(/\.\w+/, "") # normalize
        ext = Tilt.mappings.keys
        if file = Dir["./#{path}.{#{ext*','}}"].first
          Tilt.new(file)
        end
      end
  end
  
  class RenderingContext
    def initialize
      @layout = "default"
    end
    
    def layout(name=nil)
      @layout = name if name
      @layout
    end
    
    def render(template, locals={})
      Tilt.new("partials/#{template}").render(self, locals)
    end
  end
end