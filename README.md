# TruncateLog

A Ruby gem that automatically truncates large log data. It prevents oversized data structures from bloating your logs by automatically truncating them during log output.

TruncateLog helps prevent hashes, arrays, strings, and other data structures in your logs from becoming too large, improving log readability and reducing storage usage. It also supports JSON format log output.

## Features

- Automatically truncates large data structures (hashes, arrays, strings)
- Properly handles deeply nested data structures
- Customizable truncation settings
- Integrates with Ruby's standard Logger class
- Provides integration with SemanticLogger

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'truncate_log'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install truncate_log
```

## Usage

### Basic Usage

```ruby
require 'truncate_log'

# Large data structure
large_data = {
  array: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  nested: {
    deep: {
      deeper: {
        deepest: 'a' * 1000
      }
    }
  }
}

# Truncate the data
truncated_data = TruncateLog::Truncator.truncate(large_data)
puts truncated_data.to_json
```

### Customizing Configuration

```ruby
TruncateLog::Truncator.configure do |config|
  # Maximum item size (in bytes)
  config.max_item_size = 2048      # Default: 1024

  # Maximum string length
  config.max_string_length = 1024  # Default: 512

  # Maximum array items
  config.max_array_items = 10      # Default: 5

  # Maximum hash keys
  config.max_hash_keys = 20        # Default: 10

  # Maximum nesting depth
  config.max_depth = 8             # Default: 5
end
```

### Integration with Logger

```ruby
require 'logger'
require 'truncate_log'

# Create a Logger
logger = Logger.new(STDOUT)

# Set TruncateLog formatter
logger.formatter = TruncateLog::Formatter::TruncateFormatter.new

# Log messages with large data
logger.info("Large data") { large_hash_or_array }  # Automatically truncated
```

### Integration with SemanticLogger

```ruby
require 'semantic_logger'
require 'truncate_log'

# Configure SemanticLogger
SemanticLogger.default_level = :info
SemanticLogger.add_appender(
  io: STDOUT,
  formatter: TruncateLog::Formatter::SemanticLogger::Truncate.new
)

# Create a logger
logger = SemanticLogger['MyApp']

# Log messages with large payloads
logger.info(message: 'Large payload', payload: large_data)  # Automatically truncated
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hidenba/truncate_log.

## License

The gem is available as open source under the terms of the MIT License.
