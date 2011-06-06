module Sc
  # Allow ERB in Markdown templates
  class MarkdownErbTemplate < Tilt::Template
    def prepare
      @output = nil
    end
    
    def evaluate(scope, locals, &block)
      @output ||= begin
        erb = Tilt["erb"].new { data }.render(scope, locals, &block)
        Tilt::RDiscountTemplate.new { erb }.render
      end
    end
  end
  Tilt.register MarkdownErbTemplate, 'markdown', 'mkd', 'md'
  
  class ScssCompassTemplate < Tilt::ScssTemplate
    private
      def sass_options
        options.merge(Compass.sass_engine_options).
                merge(:filename => eval_file, :line => line, :syntax => :scss)
      end
  end
  Tilt.register ScssCompassTemplate, 'scss'
end