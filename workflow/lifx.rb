#!/usr/bin/env ruby
# encoding: utf-8


require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "lifx"



Alfred.with_friendly_error do |alfred|

  fb = alfred.feedback

  client = LIFX::Client.lan

  begin
    client.discover!

    sleep 1

  rescue LIFX::Client::DiscoveryTimeout => e
    $stderr.puts("Could not find any LIFX bulbs.")

    # no bulbs found
    fb.add_item({
      :uid      => "no-lifx",
      :title    => "Could not find any LIFX bulbs.",
      :subtitle => e,
      :valid    => "no",
    })

    puts fb.to_xml(ARGV)

    exit 1
  end


  client.lights.each do |c|

    color = c.color

    fb.add_item({
      :uid      => c.label,
      :title    => "Toggle " + c.label + " bulb",
      :subtitle => "It's currently %s. B: %.2f Hue: %.2f  K: %s Sat: %.2f" % [(c.on? ? "on" : "off"), color.brightness, color.hue, color.kelvin.to_s, color.saturation],
      :arg      => c.label,
      :autocomplete =>  c.label ,
      :icon     => {:type => "default", :name => (c.on? ? "icon.png" : "lifx-off.png")},
      :valid    => "yes"
    })
  end

  # add an arbitrary feedback
  fb.add_item({
    :uid      => "off",
    :title    => "Turn all off",
    :subtitle => "Turn all your bulbs off.",
    :arg      => "off",
    :valid    => "yes",
  })

  fb.add_item({
    :uid      => "on",
    :title    => "Turn all on",
    :subtitle => "Turn all your bulbs on.",
    :arg      => "on",
    :valid    => "yes",
  })

  puts fb.to_xml(ARGV)
end
