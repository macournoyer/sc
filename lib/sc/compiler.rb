module Sc
  class Compiler
    class File
      attr_reader :source_file, :type
      
      def initialize(source_file)
        @source_file = source_file
        
        @type = @source_file[/^(\w+)\//, 1]
      end
      
      def ext
        case type
        when "pages"       then "html"
        when "javascripts" then "js"
        when "stylesheets" then "css"
        end
      end
      
      def page?
        type == "pages"
      end
      
      def relative_basename
        @source_file[/^\w+\/(.*)\.\w+$/, 1]
      end
      
      def relative_filename
        "#{relative_basename}.#{ext}"
      end
      
      def destination_file
        file = relative_basename
        
        if page?
          file += "/index" if file !~ /(^|\/)index$/
        else
          file = "#{type}/#{file}"
        end
        
        "build/#{file}.#{ext}"
      end
      
      def template
        if page?
          relative_filename
        else
          "#{type}/#{relative_filename}"
        end
      end
      
      def dirname
        ::File.dirname(destination_file)
      end
    end
    
    def compile(site)
      FileUtils.mkdir_p "build"
      
      # Compile files
      Dir["{pages,javascripts,stylesheets}/**/*.*"].each do |path|
        file = File.new(path)
        
        puts "Compiling #{file.source_file} => #{file.destination_file}"
        
        content = site.render(file.template)
        
        FileUtils.mkdir_p file.dirname
        ::File.open(file.destination_file, "w") { |f| f << content }
      end
      
      # Copy static files
      Dir["public/**/*.*"].each do |file|
        dest = file.gsub(/^public/, "build")
        puts "Copying #{file} => #{dest}"
        FileUtils.mkdir_p ::File.dirname(dest)
        FileUtils.cp file, dest
      end
    end
  end
end