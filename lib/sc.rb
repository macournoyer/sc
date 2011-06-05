require 'tilt'

module Sc
  def self.build
    Site.new.build
  end
  
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
  
  class Site
    def initialize
      require "./helpers"
      RenderingContext.send :include, ::Helpers
    end
    
    def call(env)
      path = env["PATH_INFO"]
      body = render(path)
      [body ? 200 : 404, {"Content-Type" => type(path)}, [body || "Not found"]]
    end
    
    def build
      FileUtils.mkdir_p "build"
      Dir["{pages,javascripts,stylesheets}/*"].each do |file|
        type, path = file.match(/^(?:(\w+)\/)?(.*)\.\w+$/)[1..2]
        
        ext = case type
        when "pages"       then "html"
        when "javascripts" then "js"
        when "stylesheets" then "css"
        end
        
        if type == "pages"
          template = path.dup
          path += "/index" if path !~ /(^|\/)index$/
        else
          path = "#{type}/#{path}"
          template = path.dup
        end
        
        path += ".#{ext}"
        template += ".#{ext}"
        
        puts "Compiling #{file} => #{path} (#{template})"
        
        content = render(template)
        
        FileUtils.mkdir_p File.dirname("build/#{path}")
        File.open("build/#{path}", "w") { |f| f << content }
      end
    end
    
    def type(path)
      case File.extname(path)
      when ".css" then "text/css"
      when ".js"  then  "text/javascript"
      else              "text/html"
      end
    end
    
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
      
      find_template("layouts/base").render(context) { content }
    end
    
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
