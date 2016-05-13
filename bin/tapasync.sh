#!/bin/bash

#
# Sync Ruby Tapas eposides
#
# Subscribe at http://www.rubytapas.com/ and create an entry in ~/.netrc with
# the the chosen login and password:
#
# machine rubytapas.dpdcart.com
#   login me@example.com
#   password passw0rd
#

# fetch feed if too old
if test $(find ~/.rubytapas.xml -mmin +120); then
  wget --continue https://rubytapas.dpdcart.com/feed --output-document ~/.rubytapas.xml
  touch ~/.rubytapas.xml
fi

# limits itself to the number of panes that fit on a window
nokogiri -e '$_.xpath("//rss/channel/item/enclosure").to_a.shuffle.each{|n| puts n["url"]}' ~/.rubytapas.xml  |
  xargs -n 1 tmux split-window -p 99 -v wget --continue
