#!/usr/bin/env ruby
# encoding: utf-8


require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "lifx"



Alfred.with_friendly_error do |alfred|

  client = LIFX::Client.lan
  client.discover! { |c| c.lights.count >= 1 }


  case ARGV[0]
  when "off"
    client.lights.each do |c|
      c.turn_off!
    end

  when "on"
    client.lights.each do |c|
      c.turn_on!
    end

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



