Root = File.expand_path("../..", __FILE__)

map "/js" do
  run Rack::Directory.new(File.join(Root, "lib", "assets", "javascripts"))
end

run Rack::Directory.new(Root)
