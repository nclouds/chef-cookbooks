#
# Cookbook Name:: chef-client-cron
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
cron "chef-client" do 
  minute "10,20,30,40,50,0"
  command "/usr/bin/chef-client"
end
