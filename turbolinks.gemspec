Gem::Specification.new do |s|
  s.name    = 'turbolinks'
  s.version = '0.1.4'
  s.author  = 'David Heinemeier Hansson'
  s.email   = 'david@loudthinking.com'
  s.summary = 'Turbolinks makes following links in your web application faster (use with Rails Asset Pipeline)'

  s.files = ["lib/turbolinks.rb", "lib/assets/javascripts/turbolinks.js", "README.md", "MIT-LICENSE"] +
            Dir["test/*"]
  
  s.add_development_dependency 'rack'
end
