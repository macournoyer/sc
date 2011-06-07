module Sc
  module Helpers
    # Set the layout to be used
    def layout(name=nil)
      @layout = name if name
      @layout
    end
    
    # Render a partial
    def render(partial, locals={})
      render_template(Tilt.new("partials/#{partial}"), locals)
    end
    
    # Capture a block of ERB
    def capture(*args, &block)
      # Only supported in ERB for now
      outvar = @template.class.default_output_variable
      eval("#{outvar}, @#{outvar}_was = '', #{outvar}", block.binding)
      block.call(*args)
      eval(outvar, block.binding)
    ensure
      eval("#{outvar} = @#{outvar}_was", block.binding)
    end
    
    # Store a block of ERB to be rendered using +yield+
    def content_for(name, &block)
      @content_for[name] = capture(&block)
    end
  end
end