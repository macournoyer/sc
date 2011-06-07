module Sc
  class RenderingContext
    include Helpers
    
    attr_reader :page
    
    def initialize(page)
      @page = page
      @layout = "default"
      @content_for = {}
    end
    
    def site
      @page.site
    end
    
    alias asset page
    
    def render_template(template, locals={}, &block)
      @template = template
      @content_for[:layout] = block.call if block
      @template.render(self, locals) { |*names| @content_for[names.first || :layout] }
    ensure
      @template = nil
    end
  end
end