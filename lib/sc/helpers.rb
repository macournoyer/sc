module Sc
  module Helpers
    include ERB::Util
    
    # Set the layout to be used
    def layout(name=nil)
      @layout = name if name
      @layout
    end
    
    # Renders a partial
    def render(partial, locals={})
      render_template Tilt.new("partials/#{partial}"), locals
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
    
    def output_buffer(binding)
      outvar = @template.class.default_output_variable
      eval(outvar, binding)
    end
    
    # Filter +block+ w/ a give template +engine+.
    # Eg.:
    #   <% filter :haml do %>
    #     %h2 Nice
    #   <% end %>
    def filter(engine, &block)
      content = capture(&block)
      # Remove indent
      indent = content[/\n( *)/, 1]
      content.gsub!(/\n#{indent}/m, "\n")
      output_buffer(block.binding) << Tilt[engine].new { content }.render(self)
    end
    
    # Filter +block+ w/ markdown engine.
    def markdown(&block)
      filter :markdown, &block
    end
    
    # Store a block of ERB to be rendered using +yield+
    def content_for(name, &block)
      @content_for[name] = capture(&block)
    end
    
    def url_for(options)
      case options
      when Page
        options.url
      when :back
        "javascript:history.back(1);"
      when Symbol
        site.page(options.to_s).url
      else
        options
      end
    end
    
    # Renders an <a> tag pointing to a url or a page.
    def link_to(title, url_or_page=nil, options={})
      tag :a, title, options.merge(:href => url_for(url_or_page))
    end
    
    private
      def tag(name, content, options={})
        %Q{<#{name} #{tag_options(options)}>#{content}</#{name}>}
      end
      
      def tag_options(options)
        options.map { |k, v| %Q{#{k}="#{v}"} }.join(" ")
      end
  end
end