# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/ami/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-ami'
  spec.version       = Capistrano::Ami::VERSION
  spec.authors       = ['wata727']
  spec.email         = ['watassbass@gmail.com']

  spec.summary       = 'create AMI (Amazon Machine Image) and manage generations after deployment by capistrano3'
  spec.description   = "After deployed, create the instance's AMI and delete old AMI versions. If you spefied 'keep_amis', it's keep number of AMIs."
  spec.homepage      = 'https://github.com/wata727/capistrano-ami'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.0'

  spec.add_dependency 'aws-sdk', '~> 2'
  spec.add_dependency 'capistrano', '~> 3'
end
