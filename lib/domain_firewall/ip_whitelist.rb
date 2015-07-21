module DomainFirewall
  IP_RANGE = "([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])+"

  class IPWhitelist
    def initialize(app, delegate:, url: nil)
      @app = app
      @delegate = delegate
      @url = url
    end

    def call(env)
      req = Rack::Request.new(env)
      uri = URI(req.url)
      white_list = @delegate.whitelist(uri.host)

      # allow the current request if it is the same as our [url] option.
      return @app.call(env) if @url && @url == req.path

      matches?(req.ip, white_list) ? @app.call(env) : halt_chain_with_response
    end

    private

    def halt_chain_with_response
      response = Rack::Response.new
      if @url
        response.redirect(@url, 303)
      else
        response.status = 403
        response.body = [Rack::Utils::HTTP_STATUS_CODES[403]]
      end
      response.finish
    end

    def matches?(request_ip, white_list)
      return true if white_list === true
      Array(white_list).any? { |ip| request_ip =~ regexp_for_ip(ip) }
    end

    # @param ip [String] a string representing an ip. Wildcards (*) are
    # acceptable.
    # @return [Regexp]
    def regexp_for_ip ip
      Regexp.new("\\A#{ip.gsub(".", '\\.').gsub('*', IP_RANGE)}\\z")
    end
  end
end
