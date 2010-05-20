# require 'google_analytics'
# use Rack::GoogleAnalytics, 'UA-1234567-0'
# config.middleware.use ::Rack::GoogleAnalytics, 'UA-xxxxxx-x'

module Rack
  class GoogleAnalytics
    def initialize(app, id)
      @app = app
      @id = id
    end

    def call(env)
      status, headers, body = @app.call(env)

      body.each do |part|
        if part =~ /<\/head>/
          add_str = "#{tracking_code}</head>"
          part.sub!(/<\/head>/, add_str)

          if headers['Content-Length']
            headers['Content-Length'] = (headers['Content-Length'].to_i + tracking_code.length).to_s
          end

          break
        end
      end

      [status, headers, body]
    end

  private
    def tracking_code
      @tracking_code ||= <<-STR
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '#{@id}']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
STR
    end
  end
end