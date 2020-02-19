class Spree::Page < ActiveRecord::Base
  default_scope -> { order("position ASC") }

  has_and_belongs_to_many :stores, :join_table => 'spree_pages_stores'

  validates_presence_of :title
  validates_presence_of :slug, :if => :not_using_foreign_link?
  validates_presence_of :body, :if => :not_article_or_foreing_link_present?
  validates_presence_of :layout, :if => :render_layout_as_partial?

  validates :slug, :uniqueness => true, :if => :not_using_foreign_link?
  validates :foreign_link, :uniqueness => true, :allow_blank => true

  scope :visible, -> { where(:visible => true) }
  scope :header_links, -> { where(:show_in_header => true).visible }
  scope :footer_links, -> { where(:show_in_footer => true).visible }
  scope :sidebar_links, -> { where(:show_in_sidebar => true).visible }

  scope :by_store, lambda { |store| joins(:stores).where("spree_pages_stores.store_id = ?", store) }

  before_save :update_positions_and_slug
  before_save :update_token, if: :not_article_present?
  before_save :get_web_content, if: :not_article_present?

  translates :title, :body, :slug, :meta_description, :meta_keywords, :meta_title, :foreign_link, :fallbacks_for_empty_translations => true
  # Classpath bug; undefined method `whitelisted_ransackable_associations'
  include Spree::RansackableAttributes
  include SolidusGlobalize::Translatable

  def initialize(*args)
    super(*args)

    last_page = Spree::Page.last
    self.position = last_page ? last_page.position + 1 : 0
  end

  def link
    foreign_link.blank? ? slug : foreign_link
  end

  def get_web_content
    @liferay_setting = Spree::LiferaySetting.find_by(store_id: Spree::Store.default.id)
    SolidusI18n::Config.available_locales.map do |locale|
      content = SolidusLiferayConnect::ManageWebContent.get_web_content(@liferay_setting, self.article_id, locale)
      if locale == I18n.default_locale && content 
        self.body = content.force_encoding('UTF-8')
      elsif self.translations.find_by(locale: locale).present? && content 
        self.translations.find_by(locale: locale).body = content.force_encoding('UTF-8')
        if self.id.present?
          self.translations.find_by(locale: locale).update_attributes(body: content.force_encoding('UTF-8'))
        end
      elsif !self.translations.find_by(locale: locale).present? && content
        self.translations.new(locale: locale, body: content.force_encoding('UTF-8'), slug: "/#{locale}#{self.slug}", title: self.title)
      end
    end
  end

  private

  def update_positions_and_slug
    # ensure that all slugs start with a slash
    slug.prepend('/') if not_using_foreign_link? and not slug.start_with? '/'

    unless new_record?
      return unless prev_position = Spree::Page.find(self.id).position
      if prev_position > self.position
        Spree::Page.where("? <= position AND position < ?", self.position, prev_position).update_all("position = position + 1")
      elsif prev_position < self.position
        Spree::Page.where("? < position AND position <= ?", prev_position,  self.position).update_all("position = position - 1")
      end
    end
    true
  end

  def not_using_foreign_link?
    foreign_link.blank?
  end

  def not_article_or_foreing_link_present?
    !(self.article_id.present? || foreign_link.present?)
  end

  def not_article_present?
    self.article_id.present?
  end

  def update_token
    @liferay_setting ||= Spree::LiferaySetting.find_by(store_id: Spree::Store.default.id)
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
