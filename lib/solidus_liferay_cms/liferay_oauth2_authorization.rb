module SolidusLiferayConnect
  class Error < StandardError; end
  class LiferayOauth2Authorization
  	def self.client options
			client = OAuth2::Client.new(options.client_id, options.secret_id, :site => options.site_url)
			client.options[:authorize_url] = "/o/oauth2/authorize"
			client.options[:token_url] = "/o/oauth2/token"
			return client
  	end
  end
end

