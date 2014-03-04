#!/usr/bin/env ruby
# encoding: utf-8

require "bundler"
Bundler.setup

$:.unshift(File.expand_path("../../lib", __FILE__))

require 'bunny_priority_queue'
require_relative './common.rb'

begin
  conn = Bunny.new.start
  exchange = conn.create_channel.direct(EXCHANE_NAME)

  q = BunnyPriorityQueue.create(
      QUEUE_PREFIX,
      PRIORITIES,
      exchange
  )

  q.bind

  q.subscribe(:block => true) do |delivery_info, properties, body|
    puts "routing_key: #{delivery_info.routing_key}"
    puts "properties : #{properties}"
    puts "payload    : #{body}"
  end

ensure
  conn.close
end
