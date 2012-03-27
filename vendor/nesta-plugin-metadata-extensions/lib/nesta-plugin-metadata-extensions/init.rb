module Nesta
  module Plugin
    module Metadata::Extensions
      module Helpers
        # If your plugin needs any helper methods, add them here...
      end
    end
  end

  class Config
    # expose any definitions of a support contact
    def self.support
      environment_config = {}
      %w[name uri email].each do |setting|
        variable = "NESTA_SUPPORT__#{setting.upcase}"
        ENV[variable] && environment_config[setting] = ENV[variable]
      end
      environment_config.empty? ? from_yaml("support") : environment_config
    end
  end

  class App
    helpers Nesta::Plugin::Metadata::Extensions::Helpers

    # Override not_found to include additional config variables
    not_found do
      set_common_variables
      set_from_config(:support)
      haml(:not_found)
    end

    # Override error to include additional config variables
    error do
      set_common_variables
      set_from_config(:support)
      haml(:error)
    end unless Nesta::App.development?
  end

  class Page

    # Custom login to infer the page title, useful if you want to template
    # the page heading 
    def full_title
      @full_title ||= if inferred_heading
        inferred_heading
      elsif h1
        h1
      elsif title
        title
      elsif menu_label
        menu_label
      else
        "&lt;unknown&gt;"
      end
    end

    # A label for this page to be used in menus
    def menu_label
      @menu_label ||= if metadata('menu label')
        metadata('menu label')
      elsif inferred_heading
        inferred_heading
      elsif h1
        h1
      else
        "<unknown>"
      end
    end

    def h1
      metadata('h1')
    end

    def inferred_heading
      regex = case @format
        when :mdown
          /^#\s*(.*?)(\s*#+|$)/
        when :haml
          /^\s*%h1\s+(.*)/
        when :textile
          /^\s*h1\.\s+(.*)/
        end
      markup =~ regex
      Regexp.last_match(1)
    end

    def heading
      full_title
    end

    def url
      metadata('url')
    end

    def contact
      metadata('contact')
    end

  end

  module Navigation
    module Renderers
      # Override nesta's display_menu_item to show the menu attribute
      # in the menu, if given
      def display_menu_item(item, options = {})
        if item.respond_to?(:each)
          if (options[:levels] - 1) > 0
            haml_tag :li do
              display_menu(item, :levels => (options[:levels] - 1))
            end
          end
        else
          html_class = (request.path == item.abspath) ? "current" : nil
          haml_tag :li, :class => html_class do
            haml_tag :a, :<, :href => item.abspath do
              haml_concat item.menu_label
            end
          end
        end
      end

      # Override nesta's breadcrumb_label to show the menu attribute
      # in the breadcrumbs, if given
      def breadcrumb_label(page)
        if ( page != nil )
          (page.abspath == '/') ? 'Home' : ( page.metadata('menu').nil? ? page.heading : page.metadata('menu') )
        else
          'Home'
        end
      end
    end
  end

end
