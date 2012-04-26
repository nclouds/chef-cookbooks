require 'chef/knife'
require 'json'

class Chef
  class Knife
    class GogridImageList < Knife

      banner "knife gogrid image list (options)"

      def h
        @highline ||= HighLine.new
      end

      def run 
        require 'fog'
        require 'highline'
        require 'net/ssh/multi'
        require 'readline'

        connection = Fog::Compute::GoGrid.new(
          :go_grid_api_key => Chef::Config[:go_grid_api_key],
          :go_grid_shared_secret => Chef::Config[:go_grid_shared_secret] 
        )

        images  = connection.images.inject({}) { |h,i| h[i.id] = i.description; h }

        image_list = [ h.color('id', :bold), h.color('friendly_name', :bold), h.color('name', :bold) ]

        connection.images.each do |image|
          image_list << image.server_id.to_s
          image_list << image.friendly_name
          image_list << image.name
        end
        puts h.list(image_list, :columns_across, 3)

      end
    end
  end
end
