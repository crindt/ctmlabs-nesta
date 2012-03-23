# Use the app.rb file to load Ruby code, modify or extend the models, or
# do whatever else you fancy when the theme is loaded.
require 'rubygems' # Can't leave < 1.9.2 hanging...
require 'sinatra'
require 'haml'

# compass and plugins

require 'nesta-plugin-metadata-extensions'

require 'json'


module Nesta
  class App
    # Uncomment the Rack::Static line below if your theme has assets
    # (i.e images or JavaScript).
    #
    # Put your assets in themes/ctmlabs/public/ctmlabs.
    #
    use Rack::Static, :urls => ["/ctmlabs"], :root => "themes/ctmlabs/public"

    configure do        
      set :haml, { :format => :html5 }
      #set :scss, Compass.sass_engine_options
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
          haml_tag :a, :class=>"navarrow", :href => url("/#{np.path}"), :title => "See the page for #{np.full_title}" do
            #haml_concat "Next"
            haml_concat "&#187;"
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
          haml_tag :a, :class=>"navarrow", :href => url("/#{np.path}"), :title => "See the page for #{np.full_title}" do
            #haml_concat "Previous"
            haml_concat "&#171;"
          end
        end
      end

      def category_page_link_list( category, list_class = "", item_class = "" )
        ppage = Page.find_by_path(category)
        pp = Page.find_all.select do |page|
          page.date.nil? && page.url && page.flags.include?('deployed') && page.categories.include?(ppage)
        end
        # sort by priority
        pp = pp.sort do |x,y|
          by_priority = y.priority(category) <=> x.priority(category)
          if by_priority == 0
            x.heading.downcase <=> y.heading.downcase
          else
            by_priority
          end
        end
        haml_tag :ul, :class=>list_class do
          pp.each do |p|
            haml_tag :li, :class=>item_class do
              haml_tag :a, :href=>"#{p.url}", :"data-placement"=>"right", :"data-delay"=>"50", :title=>"#{p.title}" do
                haml_concat "#{p.menu || p.title}"
              end
            end
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

  # add some features to Nesta::Page
  class Page
    def image_url(index = 0)
      img = metadata('image')
      if img
        imgs = img.split(",")
        i = index
        if imgs.length - 1 < i
          i = imgs.length-1
        elsif i < 0 
          i = 0
        end
        return '/attachments/images/'+imgs[i]
      else
        return ''
      end
    end

    def url
      metadata('url')
    end

    def menu
      if metadata('menu')
        metadata('menu')
      elsif metadata('menu item')
        metadata('menu item')
      end
    end

    # filter the page listing by Tag
    def pages_with_flag(filt)
      return pages().select do |p|
        p.flags.include?(filt)
      end
    end
    def pages_without_flag(filt)
      return pages().select do |p|
        !p.flags.include?(filt)
      end
    end

    def flags
      return flag_strings
    end

    private
      def flag_strings
        strings = metadata('flags')
        strings.nil? ? [] : strings.split(',').map { |string| string.strip }
      end
  end



  module Navigation
    module Renderers

      # monkey patch menu to use "active" instead of "current" to support bootstrap
      def display_bootstrap_menu(menu, options = {})
        defaults = { :class => nil, :levels => 2 }
        options = defaults.merge(options)
        if options[:levels] > 0
          haml_tag :ul, :class => options[:class] do
            menu.each do |item|
              display_bootstrap_menu_item(item, options)
            end
          end
        end
      end
      def display_bootstrap_menu_item(item, options = {})
        if item.respond_to?(:each)
          if (options[:levels] - 1) > 0
            haml_tag :li do
              display_menu(item, :levels => (options[:levels] - 1))
            end
          end
        else
          html_class = current_item_in_path?(item) ? "current active" : nil
          haml_tag :li, :class => html_class do
            haml_tag :a, :<, :href => url(item.abspath) do
              haml_concat item.menu_label
            end
          end
        end
      end
      def current_item_in_path?(item)
        #request.path == item.abspath

        request.path =~ /#{item.abspath}/
      end
      def render_sliding_image_viewer(page)
        img = page.metadata('image')
        if img
          imgs = img.split(",")
          if imgs.length > 1
            #haml_tag :div, :id => 'slider', :class => 'nivoSlider theme-default' do
            #  imgs.each do |i|
            #    haml_tag :img, :width=>"100%", :src => '/attachments/images/'+i
            #  end
            #end
            haml_tag :div, :id => 'slides', :class => 'carousel curl' do
              haml_tag :div, :class => 'carousel-inner' do
                is_set = nil
                imgs.each do |i|
                  active = nil
                  if !is_set 
                    active = "active"
                    is_set = true
                  end
                  haml_tag :div, :class=>"item #{active}" do
                    haml_tag :img, :width=>"100%", :src => url('/attachments/images/'+i)
                    haml_tag :div, :class=>"carousel-caption" do
                      haml_concat "Caption"
                    end
                  end
                end
              end
              haml_tag :a, :class=>"carousel-control left", :href=>"#slides", :"data-slide"=>"prev" do
                haml_concat "&lsaquo;"
              end
              haml_tag :a, :class=>"carousel-control right", :href=>"#slides", :"data-slide"=>"next" do
                haml_concat "&rsaquo;"
              end
            end
          else
            haml_tag :img, :class => 'curl', :src => url('/attachments/images/'+imgs[0])
          end
        end
      end
    end
  end
end
