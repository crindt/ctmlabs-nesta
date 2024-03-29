# Use the app.rb file to load Ruby code, modify or extend the models, or
# do whatever else you fancy when the theme is loaded.
require 'rubygems' # Can't leave < 1.9.2 hanging...
require 'sinatra'
require 'haml'

# compass and plugins

require 'nesta-plugin-metadata-extensions'

require 'json'


module Nesta

  class Config
    # handle custom parameter(s) in the config.yml
    @settings.push('version')
  end

  module View
    module Helpers
      def article_summaries(articles, template = :summaries)
        haml(template, :layout => false, :locals => { :pages => articles })
      end

      def latest_articles(count = 8, categorypath = nil)
        cp = Page.find_by_path(categorypath)
        $stderr.puts "#{categorypath} ==== #{cp} "
        unless cp == nil
          all = Nesta::Page.find_articles
          all = all.select do |p|
            p.categories.include?(cp)
          end
          return all
        end
        return []
      end

      # overloading this to pull site version (which is added as a @setting above)
      def set_common_variables
        @menu_items = Nesta::Menu.for_path('/')
        @site_title = Nesta::Config.title
        set_from_config(:title, :subtitle, :google_analytics_code, :version)
        @heading = @title
      end
    end
  end
  class App
    # Uncomment the Rack::Static line below if your theme has assets
    # (i.e images or JavaScript).
    #
    # Put your assets in themes/ctmlabs/public/ctmlabs.
    #
    use Rack::Static, :urls => ["/ctmlabs"], :root => "themes/ctmlabs/public"

    # add a session for omniauth
    use Rack::Session::Cookie, :secret => 'This is a secret key'

    use OmniAuth::Builder do
      provider :cas, {
        :setup  => true,
        :cas_server => 'https://cas.ctmlabs.net/cas',
        :host => 'cas.ctmlabs.net', 
        :login_url => '/cas/login', 
        :ssl => true, 
        :service_validate_url => '/cas/serviceValidate', 
        :logout_url => '/cas/logout'
      }
    end

    configure do        
      set :haml, { :format => :html5 }
      #set :scss, Compass.sass_engine_options
    end

    helpers do
      # Add new helpers here.
      def get_user
        current_user
      end

      def urls(uri)
        turl = url(uri)
        surl = turl.sub(/^[^:]*:/,'') # return url without protocol
        surl
      end


      #### support paging through a category
      def nth_page_in_category(page,nth)
        # $stderr.puts "PAGES ARE: #{page.parent.pages.collect{|p| p.title}}"
        # $stderr.puts "NTH IS: #{nth} === #{page.parent.pages[nth].title} "
        if nth >=0 && nth < page.parent.pages.length
          return page.parent.pages[nth]
        else
          return nil
        end
      end

      def next_page_in_category(page,category)
        # find location of this page in pages
        idx = 0
        the_idx = nil
        page.parent.pages.each do |pp|
          if pp == page
            the_idx = idx
          end
          idx = idx + 1
        end
        unless (the_idx == nil) || (the_idx+1 >= page.parent.pages.length)
          return nth_page_in_category( page, the_idx + 1 )
        end
        nil
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
        # find location of this page in pages
        idx = 0
        the_idx = nil
        page.parent.pages.each do |pp|
          if pp == page
            the_idx = idx
          end
          idx = idx + 1
        end
        unless (the_idx == nil) || (the_idx+1 <= 0)
          return nth_page_in_category( page, the_idx - 1 )
        end
        nil
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

      def category_page_list( category )
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
        return pp
      end

      def category_page_link_list( category, list_class = "", item_class = "" )
        pp = category_page_list( category )
        haml_tag :ul, :class=>list_class do
          pp.each do |p|
            haml_tag :li, :class=>item_class do
              haml_tag :a, :href=>"#{p.url}", :"data-placement"=>"right", :"data-delay"=>"50", :title => "#{p.title}" do
                haml_concat "#{p.menu || p.title}"
              end
            end
          end
        end
      end
    end


    def get_ctmlabs_menu_items
      ml = category_page_list("projects")
      mil = []
      ml.each do |mi|
        mil.push({'label' => mi.menu || mi.title,
                   'title' => mi.title,
                   'url'   => mi.url
                 })
      end
      return mil
    end

    def session_has_user
      session[:user] != null
    end


    # Add new routes here.

    get '/user/register' do
      set_common_variables
      haml(:no_register)
    end

    get '/auth/cas/logout' do
      session.clear
      redirect "https://cas.ctmlabs.net/cas/logout?service=#{url('/')}"
    end

    get '/auth/failure' do
      flash[:notice] = params[:origin]
      redirect '/'
    end

    get '/auth/cas/callback' do
      # store the session in the rack/cookie
      session[:ticket] = params[:ticket]
      omniauth = request.env['omniauth.auth']
      # $stderr.puts "OMNI: #{omniauth}"
      # $stderr.puts "INFO: #{omniauth[:info]}"
      info = omniauth[:extra]
      # $stderr.puts "INFO4: #{info[:user]}"
      session[:user] = info[:user]
      session[:givenName] = info[:givenName]
      session[:sn] = info[:sn]      
      session[:cn] = info[:cn]      
      session[:groups] = info[:groups]
      
      # $stderr.puts "user:   #{session[:user]}"
      # $stderr.puts "groups: #{session[:groups]}"

      url = params[:url] || '/'

      redirect url
    end

    # Assume stylesheets are SCSS, unless...
    get '/css/:sheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      cache scss(params[:sheet].to_sym)
    end

    # return 
    get '/js/ctmlabs-banner.js' do
      set :url => 'url'
      set :title => 'title'
      set :label => 'label'
      mil = get_ctmlabs_menu_items()
      li = mil.collect{ |item| 
        '<li><a href="'+item['url']+'" title="'+item['title']+'">'+item['label']+'</a></li>' }.join("\\\n")

      f = File.open('themes/ctmlabs/public/ctmlabs/js/ctmlabs-banner.js')
      contents = f.read
      $stderr.puts "USER IS #{session[:user]}"
      proj = params['redmineproject'] || 'tb'  # default project for reporting
      if session[:user] then
        user = "<li class=\"dropdown\"><a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">#{session[:user]}<b class=\"caret\"></b></a><ul class=\"dropdown-menu\"><li><a href=\"#{urls('/auth/cas/logout')}\">Logout</a></li></ul></li>"
        manage = "<li class=\"dropdown\"><a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">Manage<b class=\"caret\"></b></a><ul class=\"dropdown-menu\"><li><a href=\"http://tracker.ctmlabs.net/projects/#{proj}/issues/new\">Report a problem</a></li><li><a href=\"http://tracker.ctmlabs.net/\">Issue Tracker</a></li><li><a href=\"https://krypton.its.uci.edu/NewQuarterly/index.cgi\">Quarterly Reports</a></li></ul></li>"
      else
        user = "<a href=\"#{url('/auth/cas')}\">Login</a>"
        manage = "<a href=\"http://tracker.ctmlabs.net/projects/#{proj}/issues/new\" title=\"Report a problem with this website\">Report Problem</a>"
      end
      cc = contents.gsub(/CTMLABSURL/,url("/"))
        .gsub(/APPURL/,params['appurl'] || url('/'))
        .gsub(/APPNAME/,params['appname'] || "CTMLabs")
        .gsub(/APPHELP/,params['apphelp'] || "docs/help")
        .gsub(/APPCONTACT/,params['appcontact'] || "docs/contact")
        .gsub(/APPLIST/,li || "")
        .gsub(/REDMINEPROJECT/,proj)
        .gsub(/MANAGEBLOCK/,manage)
        .gsub(/USERBLOCK/,user)

      if params['fixed'] == "false"
        cc = cc.gsub(/navbar-fixed-top/,'')
      end
      if params['fluid'] == 'true'
        cc = cc.gsub(/class="container"/,'class="container-fluid"')
      end

      content_type 'application/javascript', :charset => 'utf-8'
      return cc
      #res = cache( cc )
      #res.gsub(/^.*page cached.*$/,"")
    end

    # return a json object with the relevant menu items
    get '/json/ctmlabs-apps.json' do
      content_type 'application/json', :charset => 'utf-8'
      ml = category_page_list("projects")
      mil = []
      ml.each do |mi|
        mil.push({'label' => mi.menu || mi.title,
                   'title' => mi.title,
                   'url'   => mi.url
                 })
      end
      res = {'ctmlabs' => mil}.to_json 
      return res
      #cache( res )
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
        return imgs[i]
      else
        return nil
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

    def convert_to_html(format, scope, text)
      # $stderr.puts "format: #{format}"
      #text = tag_lines_of_haml(text) if @format == :haml
      template = Tilt[format].new { text }
      template.render(scope)
    end

    def render_metadata_as_markdown( meta, defhead = nil )
      text = metadata( meta )
      if text != nil
        #text = text.sub(/^#[^#].*$\r?\n(\r?\n)?/, '')
        # see if there's a heading
        if !(text =~ /^ *###.*$*/) && defhead != nil
          htxt = "### #{defhead}\n"
        else
          htxt = ""
        end
        text.gsub!('\n', "\n")
        # $stderr.puts "TEXT: #{text}"
        template = Tilt['mdown'].new{ htxt+text }
        res = template.render(nil)
        #res = convert_to_html( 'mdown', nil, text )
        # $stderr.puts "RES: #{res}"
        res
      else
        return "<div class='alert alert-warning'>This description is coming soon...</div>"
      end
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

      def render_sliding_image_viewer(page,height=350)
        img = page.metadata('image')
        if img
          imgs = img.split(",")
          if imgs.length > 1
            haml_tag :div, :id => 'slides', :class => 'carousel' do
              haml_tag :div, :class => 'carousel-inner' do
                is_set = nil
                imgs.each do |i|
                  # $stderr.puts("IMAGE IS #{i}===========")
                  active = nil
                  if !is_set 
                    active = "active"
                    is_set = true
                  end
                  haml_tag :div, :class=>"item #{active}" do
                    haml_tag :img, :height => height, :src => url(i)
                    xmp = img_xmp(i)
                    # $stderr.puts("XMP?: #{xmp}")
                    if xmp
                      xmp.namespaces.each do |nn|
                        n = xmp.send(nn)
                        n.attributes.each do |a|
                          # $stderr.puts("XMP[#{nn}.#{a}]: #{xmp.attribute_or(a,'wha?')}") #: #{n.send(a).inspect}")
                        end
                      end
                      cap = xmp.attribute_or('dc.description',nil)
                      # $stderr.puts("cap: #{cap}")                      
                      if cap && cap.length > 0
                        haml_tag :div, :class=>"carousel-caption" do
                          haml_concat "#{cap[0]}"
                        end
                      end
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
            haml_tag :img, :src => url(imgs[0]), :height => height
          end
        end
      end
    end
  end
end
