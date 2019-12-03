class CreateLiferaySettings < ActiveRecord::Migration[5.0]
  def self.up
    create_table :spree_liferay_settings do |t|
      t.string :email
      t.string :password
      t.string :token
      t.string :client_id
      t.string :secret_id
      t.string :oauth2_client
      t.string :site_url
      t.string :redirect_uri
      t.integer :group_id
      t.integer :expires_at
      t.references :store
    end
  end
  def self.down
    drop_table :spree_liferay_settings
  end
end