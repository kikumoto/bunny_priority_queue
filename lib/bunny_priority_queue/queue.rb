# -*- coding: utf-8 -*-
require "bunny"


module BunnyPriorityQueue
  class Queue
    # @param prefix [String] prefix of queue name
    # @param priorities [Array] each prirority queue names
    def initialize(prefix, priorities)
      @prefix = prefix
      @priorities = priorities
    end

    # @return [String] a priority queue name
    def name(priority)
      "#{@prefix}.#{priority}"
    end

    # create priority queues
    #
    # @return [Queue]
    # @param exchange [Bunny::Exchange] exchange
    # @param level_ttl [Integer] PriorityQueue Message TTL (msec)
    # @param queue_opts [Hash] Bunny::Queue options
    def create(exchange, level_ttl = 2000, queue_opts = {})
      @exchange = exchange

      queue_opts[:arguments] ||= {}
      args = queue_opts[:arguments]

      original_arguments = backup_arguments(args, ["x-dead-letter-exchange", "x-message-ttl", "x-dead-letter-routing-key"])

      @queues = @priorities.map.with_index do |priority, i|
        args["x-priority-level-index"] = i

        if i == 0
          original_arguments.each do |k, v|
            args[k] = v unless v.nil?
          end
        else
          # when a message is expired, its is deivered to upper priority queue fia DLX.
          args["x-dead-letter-routing-key"] = self.name(@priorities[i-1])
          args["x-message-ttl"] = level_ttl
          args["x-dead-letter-exchange"] = @exchange.name
        end

        @exchange.channel.queue("#{self.name(priority)}", queue_opts)
      end

      self
    end

    # bind queue to exchange
    #
    def bind
      @queues.each do |q|
        q.bind(@exchange, :routing_key => q.name)
      end
      self
    end

    # subscribe queue
    #
    def subscribe(opts, &block)
      manual_ack = opts[:ack] || opts[:manual_ack]
      consumers = @queues.map do |q|
        q.subscribe(:ack => true) do |delivery_info, properties, body|
          d, p, b = check_higher_queue(q.arguments["x-priority-level-index"])

          unless d.nil?
            channel.reject(delivery_info.delivery_tag, true)
            delivery_info = d
            properties = p
            body = b
          end

          channel.ack(delivery_info.delivery_tag) unless manual_ack
          yield delivery_info, properties, body
        end
      end

      if opts[:block]
        channel.work_pool.join
      end

      consumers
    end


    private

    def channel
      @exchange.channel
    end

    def check_higher_queue(current_queue_index)
      0.upto(current_queue_index -1) do |i|
        d, p, b = @queues[i].pop(:ack => true)
        return [d, p, b] unless d.nil?
      end
      
      [nil, nil, nil]
    end

    def backup_arguments(args, keys)
      original = {}
      keys.each do |k|
        original[k] = args[k]
        args.delete k
      end
      original
    end
  end
end
