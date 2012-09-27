Gem::Specification.new do |s|
  s.name    = 'turbolinks-js'
  s.version = '0.1.0'
  s.authors = ['David Heinemeier Hansson', 'Francesco Rodriguez']
  s.email   = ['lrodriguezsanc@gmail.com']
  s.summary = 'Turbolinks-js makes following links in your web application faster (use with Rails Asset Pipeline). No CoffeeScript requirement.'

  s.files = Dir['lib/assets/javascripts/*.js', 'lib/turbolinks.rb', 'README.md', 'MIT-LICENSE', 'test/*']
end
