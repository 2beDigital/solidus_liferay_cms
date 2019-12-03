module Spree
	module Admin
		class LiferaySettingsController  < ResourceController
			before_action :load_data, except: [:new]
			after_action :save_token, only: [:create]

			def get_access_token
				if save_token
					flash[:success] = Spree.t(:token_has_been_updated)
				else
					flash[:error] = Spree.t(:token_has_not_been_updated)
				end
				redirect_to edit_admin_liferay_setting_path(@liferay_setting)
			end
			
			private

			def save_token
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

			def load_data
				@liferay_setting = Spree::LiferaySetting.find_by(store_id: current_store.id)
			end
		end
	end
end