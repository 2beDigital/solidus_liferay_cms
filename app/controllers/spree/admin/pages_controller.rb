class Spree::Admin::PagesController < Spree::Admin::ResourceController
	before_action :get_body, only: [:create, :update]
	
	private

	def get_body
		update_token
		if params[:page][:translations_attributes].present?
			SolidusI18n::Config.available_locales.map do |locale|
				I18n.locale = locale
				unless @page.get_web_content(current_store, @page.article_id, locale)
					flash[:error] = Spree.t(:web_content_not_found)
				end
			end
			I18n.locale = I18n.default_locale
		elsif !@page.get_web_content(current_store,params[:page][:article_id], I18n.default_locale)
				flash[:error] = Spree.t(:web_content_not_found)
		end
		render_after_update_error if flash[:error].present?
	end

	def update_token
		@liferay_setting ||= Spree::LiferaySetting.find_by(store_id: current_store.id)
		client = SolidusLiferayConnect::LiferayOauth2Authorization.client(@liferay_setting)
		begin
			response = client.client_credentials.get_token
			@liferay_setting.update_attributes(token: response.token, oauth2_client: client)
			return true
		rescue StandardError => e
			return false
		end
	end
end
