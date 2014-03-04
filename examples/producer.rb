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

  q = BunnyPriorityQueue.new(
      QUEUE_PREFIX,
      PRIORITIES,
  )

  exchange.publish("normal", :routing_key => q.name(PRIORITY_NORMAL))
ensure
  conn.close
end