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
      white_list = Array(@delegate.whitelist(uri.host))

      # allow the current request if it is the same as our [url] option.
      return @app.call(env) if @url && @url == req.path

      response = Rack::Response.new
      if white_list.any?{|ip| req.ip =~ regexp_for_ip(ip)}
        @app.call(env)
      else
        if @url
          response.redirect(@url, 303)
        else
          response.status = 403
          response.body = [Rack::Utils::HTTP_STATUS_CODES[403]]
        end
        response.finish
      end
    end

    private

    # @param ip [String] a string represnting an ip. Wildcards (*) are
    # acceptable.
    # @return [Regexp]
    def regexp_for_ip ip
      Regexp.new("\\A#{ip.gsub(".", '\\.').gsub('*', IP_RANGE)}\\z")
    end
  end
end
