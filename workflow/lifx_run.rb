#!/usr/bin/env ruby
# encoding: utf-8


require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "lifx"



Alfred.with_friendly_error do |alfred|

  client = LIFX::Client.lan
  #client.discover! { |c| c.lights.count >= 1 }

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


  case ARGV[0]
  when "off"
    client.lights.turn_off

  when "on"
    client.lights.turn_on

  else
    # we got the label of a bulb, we want to toggle

    if c = client.lights.with_label(ARGV[0])
      if c.on?
        c.turn_off!
        puts "Turned off bulb %s." % [ARGV[0]]
      else
        c.turn_on!
        puts "Turned on bulb %s." % [ARGV[0]]
      end



    else
      puts "No bulb found with label %s." % [ARGV[0]]
    end
  end
end



