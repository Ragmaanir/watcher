require "colorize"

module Watcher
  VERSION = {{ `shards version #{__DIR__}`.strip.stringify }}

  enum Status
    Created
    Modified
    Deleted
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
               when {nil, _}     then Status::Created
               when {_, nil}     then Status::Deleted
               when {prev, prev} then nil
               else                   Status::Modified
               end

      changes[f] = status if status
    end

    State.new(state.interval, now_ts, changes)
  end

  # Allow to watch file changes using Watcher.watch
  def self.watch(pattern, interval : Int32 | Float64 = 1, skip_initial = true)
    state = State.new(interval, {} of String => Time, {} of String => Status)
    initial = true

    loop do
      state = scan(pattern, state)
      if state.changed? && !(initial && skip_initial)
        yield(state.changes, state)
      end
      initial = false
      sleep state.interval
    end
  end

  def self.print_changes(mod : String, base_path : String | Path, changes : Hash(String, Watcher::Status))
    print "#{mod}: "
    puts changes.join(", ") { |f, status|
      color = case status
              in .created?  then :green
              in .deleted?  then :red
              in .modified? then :yellow
              end

      f.gsub(base_path.to_s, "").colorize.fore(color)
    }
  end
end
