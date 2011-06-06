module Sc
  class Site
    include Rendering
    
    def initialize
      load_helpers
      load_compass
    end
    
    def call(env)
      path = env["PATH_INFO"]
      body = render(path)
      [
        body ? 200 : 404,
        {"Content-Type" => content_type_for(path)},
        [body || "Not found"]
      ]
    end
    
    private
      def load_helpers
        require "./helpers"
        RenderingContext.send :include, ::Helpers
      end
      
      def load_compass
        Compass.configuration do |config|
          config.project_path = File.dirname(__FILE__)
          config.sass_dir = 'stylesheets'
        end
      end
      
      def content_type_for(path)
        case File.extname(path)
        when ".css" then "text/css"
        when ".js"  then "text/javascript"
        else             "text/html"
        end
      end
  end
end