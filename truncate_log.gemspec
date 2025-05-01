# frozen_string_literal: true

require_relative 'lib/truncate_log/version'

Gem::Specification.new do |spec|
  spec.name = 'truncate_log'
  spec.version = TruncateLog::VERSION
  spec.authors = ['HIDEKUNI Kajita']
  spec.email = ['hide.nba@gmail.com']

  spec.summary = 'A Ruby gem that automatically truncates large log data structures'
  spec.description = 'TruncateLog helps prevent hashes, arrays, strings, and other data structures in your logs from becoming too large, improving log readability and reducing storage usage. It provides integration with Ruby\'s standard Logger and SemanticLogger.'
  spec.homepage = 'https://github.com/hidenba/truncate_log'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/hidenba/truncate_log'
  spec.metadata['changelog_uri'] = 'https://github.com/hidenba/truncate_log/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'logger', '>= 1.4.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
