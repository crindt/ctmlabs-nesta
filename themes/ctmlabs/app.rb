# Use the app.rb file to load Ruby code, modify or extend the models, or
# do whatever else you fancy when the theme is loaded.
require 'rubygems' # Can't leave < 1.9.2 hanging...
require 'sinatra'
require 'haml'

# compass and plugins
require 'compass'

#require 'compass-susy-plugin'
require 'fancy-buttons'

Compass::Frameworks.register('susy',
                             :stylesheets_directory => '/usr/local/lib/ruby/gems/1.8/gems/compass-susy-plugin-0.9/sass',
                             :templates_directory => '/usr/local/lib/ruby/gems/1.8/gems/compass-susy-plugin-0.9/templates')

Compass::Frameworks.register('sucker-compass',
                             :stylesheets_directory => File.join(File.dirname(__FILE__), 'views', 'sucker-compass'),
                             :templates_directory => File.join(File.dirname(__FILE__), 'views', 'sucker-compass'))


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
        config.preferred_syntax = :sass
        config.javascripts_dir = 'js'
        config.images_dir = 'images'
        config.http_path = "/"
      end
      set :haml, { :format => :html5 }
      set :scss, Compass.sass_engine_options
    end

    helpers do
      # Add new helpers here.
    end

    # Add new routes here.
    # Assume stylesheets are SCSS, unless...
    get '/css/:sheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      cache scss(params[:sheet].to_sym)
    end
  end
end


