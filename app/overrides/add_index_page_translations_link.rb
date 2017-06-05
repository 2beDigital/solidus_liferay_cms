Deface::Override.new(virtual_path: 'spree/admin/pages/index',
				     name: 'add_index_page_translations_link',
				     insert_bottom: "td.actions",
				     partial: 'spree/admin/pages/add_translation_link')