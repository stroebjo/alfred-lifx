#!/usr/bin/env ruby
# encoding: utf-8


require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "lifx"



Alfred.with_friendly_error do |alfred|

  client = LIFX::Client.lan
  #client.discover! { |c| c.lights.count >= 1 }


  arguments  = ARGV[0].split # if a split pattern is omitted, whitespaces are the default
  bulb       = arguments[1]
  color_type = arguments[0]



  case bulb
  when "all"

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
      color = LIFX::Color.random_color
      c.set_color(color)
    end
  else

    client.discover! do |c|                    # Discover lights. Blocks until a light with the label 'Office' is found
      c.lights.with_label(bulb)
    end

    if c = client.lights.with_label(bulb)

      if c.off?
        c.turn_on!
      end

      case color_type
      when /^#[0-9a-f]{6}$/
        m = color_type.match /#(..)(..)(..)/
        color = LIFX::Color.rgb(m[1].hex, m[2].hex, m[3].hex)
        puts "Set color to %s for %s bulb." % [color_type, bulb]
      else
        color = LIFX::Color.random_color
        puts "Set random color for %s bulb." % [bulb]
      end

      c.set_color(color)
  else
      puts "No bulb found with label %s." % [bulb]
    end
  end

  sleep 5 # let the settings be pushed to the bulb

end




