require 'yaml'
YAML::ENGINE.yamler = 'syck'

require 'xmp'
require 'exifr'

# Extend XMP with a few helpers
class XMP
  def attribute_or(attr, default = "Attribute #{attr} missing from image")
    attra = attr.split(".")
    if attra.length == 2
      begin
        return self.send(attra[0]).send(attra[1])
      rescue
        return default
      end
    end
    return default
  end
end


module Nesta
  class App
    # Uncomment the Rack::Static line below if your theme has assets
    # (i.e images or JavaScript).
    #
    # Put your assets in themes/test2/public/test2.
    #
    use Rack::Static, :urls => ["/paths"], :root => "themes/paths/public"
    def page_img(img = nil)
      img ||= get_image_or_parent
      if img
        pimg = img.split(",").first
        imgdata = pimg.split(":");
        haml_tag :div, :class => 'pageimage', :style => "background-image:url(#{imgdata.first});#{imgdata[1]?'background-position:'+imgdata[1]:''}", :width => 200
      end
    end

    def img_xmp( i )
      fn = i.split(":").first
      fn = fn ? "content"+fn : nil
      f = nil
      begin
        f = EXIFR::JPEG.new(fn)
      rescue
        warn "can't find image #{fn} from #{Dir.pwd}"
        return nil
      end
      if f 
        xmp = XMP.parse(f)
        return xmp
      end
      nil
    end

    def detail_img(img = nil)
      img ||= get_image_or_parent(1)
      if img
        dimg = img.split(",")[1]
        if dimg != nil
          imgdata = dimg.split(":");
          xmp = img_xmp(imgdata.first)
          an = 'PATHS Inc.'
          xr = 'This image is copyrighted with all rights reserved by #{an}.'
          au = 'http://www.pathstherapy.com/copyrights'
          if xmp != nil
            an = xmp.attribute_or('cc.attributionName','PATHS Inc.')
            xr = xmp.attribute_or('xmpRights.UsageTerms', 'This image is copyrighted with all rights reserved by #{an}.' )
            au = xmp.attribute_or('cc.attributionURL', 'http://www.pathstherapy.com/copyrights' )
          end
          haml :detail_img, :layout => false,  :locals => { :src => imgdata.first, :rel => "oly-#{imgdata.first.gsub(/[\/\.]/,'-')}", :an => an, :xr => xr, :au => au }
        end
      end
    end

    def img_attribution
      bg = get_image_or_parent(0)
      d = get_image_or_parent(1)
      bg = bg == nil ? nil : bg.split(",").first
      d = d == nil ? nil : d.split(",")[1]
      imgs = [bg,d].map { |i| i != nil ? img_xmp(i) : nil }.find_all do |xmp| 
        an = xmp == nil ? "NONE" : xmp.attribute_or('cc.attributionName', 'PATHS Inc.')
        xmp != nil && /^PATHS/.match(an) == nil
      end
      if imgs.length > 0
        haml_tag :div do
          haml_tag :span, "Some images copyright: "
          haml_tag :ul, :class => 'image-attribution' do
            imgs.each do |xmp|
              an = xmp.attribute_or('cc.attributionName','PATHS Inc.')
              xr = xmp.attribute_or('xmpRights.UsageTerms', 'This image is copyrighted with all rights reserved by #{an}.' )
              au = xmp.attribute_or('cc.attributionURL', 'http://www.pathstherapy.com/copyrights' )
              haml_tag :li do 
                haml_tag :a, :href => au do
                  haml_tag :span, an
                end
              end
            end
          end
        end
      end
    end

    helpers do
      # Add new helpers here.
    end
  end
end
