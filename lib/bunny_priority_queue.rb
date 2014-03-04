# -*- encoding: utf-8; mode: ruby -*-

require "bunny"

require "bunny_priority_queue/version"
require "bunny_priority_queue/queue"

module BunnyPriorityQueue
  # @return [String] Bunny version
  def self.version
    VERSION
  end

  # Instantiates a new priority queue.
  #
  # @return [BunnyPriorityQueue::Queue]
  # @see BunnyPriorityQueue::Queue#initialize
  # @api public
  def self.new(prefix, priorities)
    Queue.new(prefix, priorities)
  end

  # Instantiates a new priority queue and create queue.
  #
  # @return [BunnyPriorityQueue::Queue]
  # @see BunnyPriorityQueue::Queue#initialize
  # @see BunnyPriorityQueue::Queue#create
  # @api public
  def self.create(prefix, priorities, exchange, level_ttl = 2000, queue_opts = {})
    q = Queue.new(prefix, priorities)
    q.create(exchange, level_ttl, queue_opts)
    q
  end
end
