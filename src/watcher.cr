require "./watcher/*"

module Watcher
  enum Status
    CREATED
    MODIFIED
    DELETED
  end

  class State
    getter timestamps : Hash(String, Time)
    getter changes : Hash(String, Status)
    getter interval : Int32 | Float64

    def initialize(@interval, @timestamps, @changes)
    end

    def changed?
      !changes.empty?
    end
  end

  # Get file timestamp using File.stat
  def self.timestamp_for(file : String) : Time
    File.info(file).modification_time
  end

  private def self.scan(pattern, state : State)
    changes = {} of String => Status
    prev_ts = state.timestamps
    now_ts = Dir.glob(pattern).map { |f| {f, timestamp_for(f)} }.to_h

    all_files = (prev_ts.keys + now_ts.keys).uniq

    all_files.each do |f|
      prev = prev_ts[f]?
      now = now_ts[f]?

      status = case {prev, now}
               when {nil, nil}   then nil
               when {nil, _}     then Status::CREATED
               when {_, nil}     then Status::DELETED
               when {prev, prev} then nil
               else                   Status::MODIFIED
               end

      changes[f] = status if status
    end

    State.new(state.interval, now_ts, changes)
  end

  # Allow to watch file changes using Watcher.watch
  def self.watch(pattern, interval : Int32 | Float64)
    state = State.new(interval, {} of String => Time, {} of String => Status)

    loop do
      state = scan(pattern, state)
      yield(state.changes, state) if state.changed?
      sleep state.interval
    end
  end

  def self.watch(pattern)
    self.watch(pattern, 1) do |*args|
      yield(*args)
    end
  end
end
