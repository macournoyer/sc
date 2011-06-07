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
      
      return nil unless template
      
      context = RenderingContext.new
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
      def find_template(path)
        path = path.gsub(/\.\w+/, "") # normalize
        ext = Tilt.mappings.keys
        if file = Dir["./#{path}.{#{ext*','}}"].first
          Tilt.new(file)
        end
      end
  end
  
  class RenderingContext
    include Helpers
    
    def initialize
      @layout = "default"
      @content_for = {}
    end
    
    def render_template(template, locals={}, &block)
      @template = template
      @content_for[:layout] = block.call if block
      @template.render(self, locals) { |*names| @content_for[names.first || :layout] }
    ensure
      @template = nil
    end
  end
end