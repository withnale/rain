# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','rain','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'rain'
  s.version = Rain::VERSION
  s.author = 'withnale'
  s.email = 'withnale@users.noreply.github.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A CLI interface for managing VCloud environments'
# Add your other files here if you make them
  s.files = %w(
bin/rain
lib/rain/version.rb
lib/rain.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.bindir = 'bin'
  s.executables << 'rain'

  s.add_dependency "i18n", "~> 0.6.0"

  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
end
