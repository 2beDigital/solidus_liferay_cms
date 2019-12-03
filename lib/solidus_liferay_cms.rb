require 'solidus_core'
require 'solidus_frontend'
require 'solidus_backend'
require 'deface'
require 'solidus_liferay_cms/engine'
require 'solidus_liferay_cms/liferay_oauth2_authorization'
require 'solidus_liferay_cms/manage_web_content'
require 'coffee_script'
require 'sass/rails'

module StaticPage
  def self.remove_spree_mount_point(path)
    regex = Regexp.new '\A' + Rails.application.routes.url_helpers.spree_path
    path.sub( regex, '').split('?')[0]
  end
end

class Spree::StaticPage
  def self.matches?(request)
    return false if request.path =~ /(^\/+(admin|account|cart|checkout|content|login|pg\/|orders|products|s\/|session|signup|shipments|states|t\/|tax_categories|user)+)/
    !Spree::Page.visible.with_translations.find_by(slug: request.path).nil?
  end
end