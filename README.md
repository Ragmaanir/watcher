<p align="center"><img src="logo/logotype_horizontal.png" alt="watcher" height="100px"></p>

[![Build Status](https://travis-ci.org/faustinoaq/watcher.svg?branch=master)](https://travis-ci.org/faustinoaq/watcher)

Crystal shard to watch file changes. This shard use the same code implemented [here (Guardian)](https://github.com/f/guardian/blob/master/src/guardian/watcher.cr#L45) and [here (Sentry)](https://github.com/samueleaton/sentry/blob/master/src/sentry.cr#L52).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  watcher:
    github: faustinoaq/watcher
```

## Usage

Use the `Watcher.watch` to watch files or file groups, for example:

```crystal
require "watcher"

Watcher.watch("src/assets/js/*.js") do |changes, state|
  # changes is a Hash(String, Watcher::Status)
  # status is CREATED | MODIFIED | DELETED
  changes.each do |name, status|
    puts "{status}: #{name}"
  end
end
```

Also you can have more than one watcher, just use `spawn`

```crystal
spawn do
  Watcher.watch(["src/assets/*.css", "src/views/*.html"]) do |changes|
    # ...
  end
end

# Other watcher
Watcher.watch(...) do |changes|
 # ...
end
```

And you can change time interval for a watcher.

```crystal
Watcher.watch("public/*.json", interval: 0.5) do |changes|
  # ...
end
```

# How does it work?

Watcher uses timestamps to check file changes every second, if you want some more advanced then you can use [Watchbird](https://github.com/agatan/watchbird) that uses `libnotify` to check events like modify, access and delete but just work in Linux for now.

## Contributing

1. Fork it ( https://github.com/faustinoaq/watcher/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [faustinoaq](https://github.com/faustinoaq) Faustino Aguilar - creator, maintainer
