require 'chef'
require 'json'
require "chef/knife/core/bootstrap_context"
        require "chef/json_compat"
        require "tempfile"
        require "highline"
        require "net/ssh"
        require "net/ssh/multi"
        Chef::Knife::Ssh.load_deps
class Chef
  class Knife
    class GogridServerCreate < Knife

      banner "knife gogrid server create [RUN LIST...] (options)"

      option :address,
        :short => "-a IP_ADDRESS",
        :long => "--address IP_ADDRESS",
        :description => "The ip address of server"

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      option :image,
        :short => "-i IMAGE",
        :long => "--image IMAGE",
        :description => "The image of the server"

      option :server_name,
        :short => "-N NAME",
        :long => "--server-name NAME",
        :description => "The server name"

      option :memory,
        :short => "-R RAM",
        :long => "--server-memory RAM",
        :description => "Server RAM amount",
        :default => "1GB"

      option :template_file,
        :long => "--template-file TEMPLATE",
        :description => "Full path to location of template to use",
        :default => false

      def h
        @highline ||= HighLine.new
      end

      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::ECONNREFUSED
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
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

	server = connection.grid_server_add( config[:image], config[:address], config[:server_name], config[:memory])

	server1_ip = config[:address]
	server1_image_id = config[:image]
	server1_name = config[:server_name]
	server1_memory = config[:memory]

	$stdout.sync = true

        puts "#{h.color("Hostname", :cyan)}: #{server1_name}"
        puts "#{h.color("IP Address", :cyan)}: #{server1_ip}"
        puts "#{h.color("Server Image", :cyan)}: #{server1_image_id}"
        puts "#{h.color("Amount of RAM", :cyan)}: #{server1_memory}"
        puts "#{h.color("Default Root Password", :cyan)}:  #{@root_passwd}"

        puts "\nBootstrapping #{h.color(server1_name, :bold)}..."

        print "\n#{h.color("Provisioning server at GoGrid", :magenta)}"

        # wait for it to be ready to do stuff
        #server.wait_for { print "."; ready? }

        puts("\n")
	sleep 30

        print "\n#{h.color("Waiting for sshd", :magenta)}"

        print(".") until tcp_test_ssh(server1_ip) { sleep @initial_sleep_delay ||= 10; puts("done") }

	connection.servers.each do |s|
	  if s.name == (config[:server_name])
		@server_id = s.id
	  end
	end

        connection.passwords.each do |p|
	  if p.server.nil?
		puts""
	  else
            if p.server['id'] == @server_id
                  @root_passwd = p.password
                  puts p.password
	    end
          end
        end
        bootstrap_for_node(server,server1_ip).run

        puts "#{h.color("Hostname", :cyan)}: #{server1_name}"
        puts "#{h.color("IP Address", :cyan)}: #{server1_ip}"
        puts "#{h.color("Server Image", :cyan)}: #{server1_image_id}"
        puts "#{h.color("Amount of RAM", :cyan)}: #{server1_memory}"
        puts "#{h.color("Default Root Password", :cyan)}:  #{@root_passwd}"

        puts "\nBootstrapping #{h.color(server1_name, :bold)}..."
      end
      
      def bootstrap_for_node(server,server1_ip)
	bootstrap = Chef::Knife::Bootstrap.new
         bootstrap.name_args = server1_ip
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] = "root"
        bootstrap.config[:ssh_password] = @root_passwd
        bootstrap.config[:chef_node_name] = config[:server_name] || server.id
        bootstrap.config[:use_sudo] = false
        bootstrap.config[:template_file] = config[:template_file]
        #bootstrap.config[:environment] = config[:environment]
	bootstrap
      end
    end
  end
end
