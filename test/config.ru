require 'sprockets'
require 'coffee-script'

Root = File.expand_path("../..", __FILE__)

Assets = Sprockets::Environment.new do |env|
  env.append_path File.join(Root, "lib", "assets", "javascripts")
end

map "/js" do
  run Assets
end

map "/redirect.html" do
  run lambda { |env| [302, { "Content-Type" => "text/html", "Location" => "/redirect_target.html" }, []] }
end

map "/redirect_target.html" do
  run Rack::File.new(File.expand_path("../redirect_target.html", __FILE__), {"X-XHR-Redirected-To" => "/redirect_target.html"})
end

map "/500" do
  # throw Internal Server Error (500)
end

map "/" do
  run Rack::Directory.new(File.join(Root, "test"))
end
