Spree::Store.class_eval do
	has_one :liferay_settings, dependent: :destroy
end