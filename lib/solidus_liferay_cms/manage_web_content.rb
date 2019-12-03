module SolidusLiferayConnect
  class ManageWebContent
  	require 'net/http'
		require 'uri'

		def self.get_web_content(options,id,locale)
			uri = URI.parse("#{options.site_url}/api/jsonws/journal.journalarticle/get-article-content")
			locale = 'en_US' if locale == :en
			request = Net::HTTP::Post.new(uri)

			if options.token.present?
				request["Authorization"] = "Bearer #{options.token}"
			else
				request.basic_auth(options.email, options.password)
			end

			request.set_form_data(
			  "-themeDisplay" => "",
			  "articleId" => "#{id}",
			  "groupId" => "#{options.group_id}",
			  "languageId" => "#{locale}",
			)

			req_options = {
			  use_ssl: uri.scheme == "https",
			}

			response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
			  http.request(request)
			end

			if response.code == '200' || response.code == '201'
				return eval(response.body)
			else
				return false
			end
			
		end
  end
end