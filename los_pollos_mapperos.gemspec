require_relative "lib/los_pollos_mapperos/version"

Gem::Specification.new do |spec|
  spec.name          = "los_pollos_mapperos"
  spec.version       = LosPollosMapperos::VERSION
  spec.authors       = ["Michał Wiącek"]
  spec.email         = ["michal.wiacek.90@gmail.com"]

  spec.summary       = "CLI tool for updating GraphQL field definitions based on DB column types."
  spec.description   = "A generic tool that fetches column information directly from the database and updates corresponding GraphQL object definitions using configurable mappings."
  spec.homepage      = "https://github.com/twoje_repo/los_pollos_mapperos"
  spec.license       = "MIT"

  # Listowanie plików ręcznie, aby uniknąć zależności od gita.
  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "los_pollos_mapperos.gemspec"]
  spec.executables   = ["los_pollos_mapperos"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7"

  # Zależności z ograniczoną wersją.
  spec.add_dependency "active_record", "~> 6.1"
  spec.add_dependency "active_support", "~> 6.1"
end
