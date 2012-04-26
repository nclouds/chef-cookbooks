Description
===========

Knife scripts which provides support for gogrid api

Installation
============

Copy gogrid_create_server.rb, gogrid_delete.rb and gogrid_images.rb to ~/.chef/plugins/knife/

Configuration:
==============

In order to communicate with the API of GoGrid you have tell Knife about your GoGrid api key and GoGrid shared keys. Edit your knife.rb and these lines in there

    go_grid_api_key =  "Your GoGrid api key"
    go_grid_shared_secret = "Your GoGrid shared key"


