#
# Cookbook Name:: timezone
# Recipe:: default
#
# Copyright 2012, nclouds.com
#
# All rights reserved - Do Not Redistribute
#
link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{node[:timezone]}"
end
