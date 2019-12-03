class Spree::Admin::PagesController < Spree::Admin::ResourceController
	before_action :get_body, only: [:create, :update]
	
	private

	def get_body
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
end
