# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cursor_pagination/version'

Gem::Specification.new do |spec|
  spec.name          = "cursor_pagination"
  spec.version       = CursorPagination::VERSION
  spec.authors       = ["Sergey Kukunin"]
  spec.email         = ["sergey.kukunin@gmail.com"]
  spec.description   = %q{ActiveRecord plugin for cursor based pagination. Uses some column and rpp (results per page) to paginate your content. The main advantage against traditional pagination (limmit and offset), that the one URL on specific page will contain the data set, despite the newly added entities. It may be useful on the projects, where new entities are added often, and specific page now isn't specific page tomorrow.}
  spec.summary  	 = %q{ActiveRecord plugin for cursor based pagination}
  spec.homepage      = "https://github.com/Kukunin/cursor_pagination"
  spec.license       = "MIT"

  spec.add_dependency "activerecord", ['>= 3.0.0']
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3-ruby"
  spec.add_development_dependency "database_cleaner", ['< 1.1.0']

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
