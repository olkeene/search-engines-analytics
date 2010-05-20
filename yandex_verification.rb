# require 'yandex_verification'
# use Rack::YandexVerification, 'UA-1234567-0'
# config.middleware.use ::Rack::YandexVerification, 'UA-xxxxxx-x'

module Rack
  class YandexVerification
    def initialize(app, code)
      @app = app
      @code = code
    end

    def call(env)
      status, headers, body = @app.call(env)

      body.each do |part|
        if part =~ /<head>/
          add_str = "<head>\n#{tracking_code}"
          part.sub!(/<head>/, add_str)

          if headers['Content-Length']
            headers['Content-Length'] = (headers['Content-Length'].to_i + add_str.length).to_s
          end

          break
        end
      end

      [status, headers, body]
    end

  private
    def tracking_code
      @tracking_code ||= "<meta name='yandex-verification' content='#{@code}' />"
    end
  end
end