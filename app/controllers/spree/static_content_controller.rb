class Spree::StaticContentController < Spree::StoreController
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  helper 'spree/products'
  layout :determine_layout

  def show
    @page = Spree::Page.by_store(current_store).visible.find_by!(slug: request.path)
    if (Time.now - @page.updated_at) > 30.second
      begin
        @page.get_web_content(current_store,@page.article_id, I18n.locale)
        @page.save
      rescue Exception => e
        false
      end
    end
  end

  private
    def determine_layout
      return @page.layout if @page and @page.layout.present? and not @page.render_layout_as_partial?
      Spree::Config.layout
    end

    def accurate_title
      @page ? (@page.meta_title.present? ? @page.meta_title : @page.title) : nil
    end
end
