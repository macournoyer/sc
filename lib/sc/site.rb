module Sc
  class Site
    def initialize
      load_helpers
      load_compass
    end
    
    def call(env)
      reload!
      if file = file_for_url(env["PATH_INFO"])
        [200, {"Content-Type" => file.content_type}, [file.render]]
      else
        [404, {"Content-Type" => "text/plain"}, ["Not found"]]
      end
    end
    
    def compile
      FileUtils.mkdir_p "build"
      
      compilable_files.each do |file|
        unless file.partial?
          puts "Compiling #{file.source_filename} => #{file.compiled_filename}"
          
          content = file.render
          
          FileUtils.mkdir_p ::File.dirname(file.compiled_filename)
          ::File.open(file.compiled_filename, "w") { |f| f << content }
        end
      end
      
      static_files.each do |file|
        dest = file.gsub(/^public/, "build")
        puts "Copying #{file} => #{dest}"
        FileUtils.mkdir_p ::File.dirname(dest)
        FileUtils.cp file, dest
      end
    end
    
    def reload!
      @pages = @assets = @compilable_files = nil
      reload_helpers
    end
    
    def pages
      @pages ||= files("pages").map { |path| Page.new(self, path) }
    end
    
    def pages_in(directory, recursive=true)
      if recursive
        pages.select { |page| page.directory =~ /^#{directory}/ }
      else
        pages.select { |page| page.directory == directory }
      end
    end
    
    def page(name)
      pages.detect { |page| page.name == name }
    end
    
    def assets
      @assets ||= files("assets/*").map { |path| Asset.new(self, path) }
    end
    
    def file_for_url(url)
      compilable_files.detect { |file| file.url == url }
    end
    
    def compilable_files
      @compilable_files ||= pages + assets
    end
    
    def static_files
      Dir["public/**/*.*"]
    end
    
    private
      def files(path)
        Dir["site/#{path}/**/*.*"]
      end
    
    private
      def reload_helpers
        load "./site/helpers.rb"
      end
      
      def load_helpers
        reload_helpers
        RenderingContext.send :include, ::Helpers
      end
      
      def load_compass
        Compass.configuration do |config|
          config.project_path = File.dirname(__FILE__)
          config.sass_dir = 'site/assets/stylesheets'
        end
      end
  end
end