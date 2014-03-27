# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sn_do"
  spec.version       = '0.0.1'
  spec.authors       = ["Tom Mc Mahon"]
  spec.email         = ["thomasmc@gmail.com"]
  spec.description   = %q{Used for creating slide decks backed by reveal.js}
  spec.summary       = %q{Used for creating slide decks backed by reveal.js}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]d
