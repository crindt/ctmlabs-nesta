# Use the app.rb file to load Ruby code, modify or extend the models, or
# do whatever else you fancy when the theme is loaded.
require 'rubygems' # Can't leave < 1.9.2 hanging...
require 'sinatra'
require 'haml'

# compass and plugins
require 'compass'

#require 'compass-susy-plugin'
require 'fancy-buttons'

require 'nesta-plugin-metadata-extensions'

require 'json'


Compass::Frameworks.register('susy',
                             :stylesheets_directory => '/usr/local/lib/ruby/gems/1.8/gems/compass-susy-plugin-0.9/sass',
                             :templates_directory => '/usr/local/lib/ruby/gems/1.8/gems/compass-susy-plugin-0.9/templates')

#Compass::Frameworks.register('sucker-compass',
#                             :stylesheets_directory => File.join(File.dirname(__FILE__), 'views', 'sucker-compass'),
#                             :templates_directory => File.join(File.dirname(__FILE__), 'views', 'sucker-compass'))


module Nesta
  class App
    # Uncomment the Rack::Static line below if your theme has assets
    # (i.e images or JavaScript).
    #
    # Put your assets in themes/ctmlabs/public/ctmlabs.
    #
    use Rack::Static, :urls => ["/ctmlabs"], :root => "themes/ctmlabs/public"

    configure do        
      Compass.configuration do |config|
        config.project_path = File.dirname(__FILE__)
        config.sass_dir = 'views'
        config.environment = :development
        config.relative_assets = true
        config.preferred_syntax = :scss
        config.javascripts_dir = 'js'
        config.images_dir = 'images'
        config.http_path = "/"
      end
      set :haml, { :format => :html5 }
      set :scss, Compass.sass_engine_options
    end

    helpers do
      # Add new helpers here.
      def get_user
        current_user
      end


      #### support paging through a category
      def nth_page_in_category(page,nth)
        $stderr.puts "PAGES ARE: #{page.pages}"
        return page.parent.pages[nth]
      end

      def next_page_in_category(page,category)
        next_idx = (-1*page.priority( category ))
        unless next_idx == nil
          return nth_page_in_category( page, next_idx )
        end
      end

      def next_page_link( page, category )
        np = next_page_in_category( page, category )
        unless np == nil
          haml_tag :a, :href => "/#{np.path}" do
            haml_concat "Next"
          end
        end
      end

      def prev_page_in_category(page,category)
        prev_idx = (-1*page.priority( category )-2)
        unless prev_idx == nil
          return nth_page_in_category( page, prev_idx )
        end
      end

      def prev_page_link( page, category )
        np = prev_page_in_category( page, category )
        unless np == nil
          haml_tag :a, :href => "/#{np.path}" do
            haml_concat "Previous"
          end
        end
      end
    end

    # Add new routes here.

    # Assume stylesheets are SCSS, unless...
    get '/css/:sheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      cache scss(params[:sheet].to_sym)
    end
  end
end
