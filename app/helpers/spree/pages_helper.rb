module Spree::PagesHelper
  def render_snippet(slug)
  	cache_key = "render-snippet-#{slug}"
		Rails.cache.fetch("#{cache_key}/page", expires_in: 6.hour) do
	    page = Spree::Page.find_by(slug: slug)
	    if page
		    page.get_web_content(current_store,page.article_id, I18n.locale)
	      page.save
		    raw page.body
		  end
		end
  end
end