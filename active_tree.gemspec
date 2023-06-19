# frozen_string_literal: true

require_relative "lib/active_tree/version"

Gem::Specification.new do |spec|
  spec.name          = "active_tree"
  spec.version       = ActiveTree::VERSION
  spec.authors       = ["Nick"]
  spec.email         = ["spam@flinkwise.com"]

  spec.summary       = "Helps managing partitioned trees/graphs within postgresql."
  spec.description   = "This gem lets you manage partitioned tree structures or graphs using PostgreSQL as data store"
  spec.homepage      = "https://github.com/nicksterious/active_tree"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  #spec.metadata["allowed_push_host"] = "to do Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nicksterious/active_tree"
  spec.metadata["changelog_uri"] = "https://github.com/nicksterious/active_tree/CHANGELOG.md"
  # additional links
  spec.metadata["bug_tracker_uri"] = "https://www.white-label-sportsbook.net"
  spec.metadata["mailing_list_uri"] = "https://www.sportsbook-white-label.com"
  spec.metadata["wiki_uri"] = "https://www.white-label-sportsbook.com"
  spec.metadata["funding_uri"] = "https://www.turnkeysportsbook.software"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
