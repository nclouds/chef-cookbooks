require 'chef/knife'
require 'json'

class Chef
  class Knife
    class GogridServerDelete < Knife

      banner "knife gogrid server delete SERVER (options)"

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

        server = connection.servers.get(@name_args[0])

        confirm("Do you really want to delete server ID #{server.id} named #{server.name}")

        server.destroy

        Chef::Log.warn("Deleted server #{server.id} named #{server.name}")
      end
    end
  end
end
