class RobotsTxt
  def initialize(app)
    @app = app
  end

  def call(env)
    env['PATH_INFO'] == '/robots.txt' ? robots_response(env) : @app.call(env)
  end

  def robots_response(env)
    req = Rack::Request.new(env)

    url = req.scheme + "://"
    url << req.host
    url << ":#{req.port}" if req.scheme == "https" && req.port != 443 || req.scheme == "http" && req.port != 80
    url << '/sitemap.xml'

    Rack::Response.new do |res|
      res.header['Content-Type'] = 'text/plain'
      res.write "User-agent: *\nDisallow: /admin/*\n"
      res.write "Disallow: /images/*\n"
      res.write "Disallow: /assets/*\n"
      res.write "Disallow: /javascripts/*\n"
      res.write "Allow: /\n"
      res.write "Sitemap: #{url}\n"
    end.finish
  end
end
