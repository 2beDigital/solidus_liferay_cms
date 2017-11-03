module Spree::PagesHelper
  def render_snippet(slug)
    page = Spree::Page.find_by_slug(slug)
    raw page.body if page
  end

  #Allows to generate the correct url for each page and each locale. Call it from your views
  def switch_language(locale)
		page = Spree::Page.visible.with_translations.find_by(slug: request.path)
		if page.nil?
			url_for(:locale => locale)
		else
			Spree::Page::Translation.where(spree_page_id: page.id, locale: locale).first.slug
		end
	end
end