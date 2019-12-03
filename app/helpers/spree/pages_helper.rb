module Spree::PagesHelper
  def render_snippet(slug)
  	cache_key = "render-snippet-#{slug}"
		Rails.cache.fetch("#{cache_key}/page", expires_in: 1.hour) do
	    page = Spree::Page.find_by(slug: slug)
	    page.get_web_content(current_store,page.article_id, I18n.locale) if page
      page.save
	    raw page.body if page
		end
  end
end