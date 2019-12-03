class AddArticleIdToSpreePages < ActiveRecord::Migration[5.0]
	def self.up
		add_column :spree_pages, :article_id, :string
	end

	def self.down
		remove_column :spree_pages, :article_id
	end
end