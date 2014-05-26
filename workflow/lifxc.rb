#!/usr/bin/env ruby
# encoding: utf-8


require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "lifx"


def is_valid_color(color)

  if color == "random"
    return true
  end

  return color.match /^#[0-9a-f]{6}$/
end





Alfred.with_friendly_error do |alfred|

  fb = alfred.feedback






  if ARGV[0].length > 0 && is_valid_color(ARGV[0])

    # list bulbs to wich the color should be applied

    client = LIFX::Client.lan

    begin
      client.discover!
      sleep 1
    rescue LIFX::Client::DiscoveryTimeout => e
      $stderr.puts("Could not find any LIFX bulbs.")

      # no bulbs found
      fb.add_item({
        :uid      => "no-lifx",
        :title    => "Could not find any LIFX bulbs",
        :subtitle => e,
        :valid    => "no",
      })

      puts fb.to_xml(ARGV)

      exit 1
    end


    client.lights.each do |c|
      color = c.color
      fb.add_item({
        :uid      => c.label ,
        :title    => "Set the color of %s bulb to %s" % [c.label, ARGV[0]],
        :subtitle => "It's currently %s. B: %.2f Hue: %.2f  K: %s Sat: %.2f" % [(c.on? ? "on" : "off"), color.brightness, color.hue, color.kelvin.to_s, color.saturation],
        :arg      => "%s %s" % [ARGV[0], c.label],
        :icon     => {:type => "default", :name => (c.on? ? "icon.png" : "lifx-off.png")},
        :valid    => "yes"
      })
    end

  else

    # define color

    fb.add_item({
      :uid      => "random",
      :title    => "Random color",
      :subtitle => "Set a bulb to a random color.",
      :autocomplete => 'random',
      :arg      => "random",
      :valid    => "no",
    })

    # catch every query
    if ARGV[0].length > 0
      fb.add_item({
        :uid      => "",
        :title    => ARGV[0],
        :subtitle => "Set a bulb to the color %s." % [ARGV[0]],
        :arg      => ARGV[0],
        :valid    => "no" ,
      })
    end
  end

  puts fb.to_xml(ARGV)
end




