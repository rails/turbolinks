Gem::Specification.new do |s|
  s.name     = 'turbolinks-js'
  s.version  = '0.5.1'
  s.authors  = ['David Heinemeier Hansson', 'Francesco Rodriguez']
  s.email    = ['lrodriguezsanc@gmail.com']
  s.summary  = 'Same as Turbolinks but without the CoffeeScript requirement'
  s.homepage = 'https://github.com/epiclabs/turbolinks-js/'

  s.files = Dir['lib/assets/javascripts/*.js', 'lib/turbolinks.rb', 'README.md', 'MIT-LICENSE', 'test/*']
end
