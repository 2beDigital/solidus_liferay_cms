Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :pages
    resources :liferay_settings
    post :get_access_token, to: 'liferay_settings#get_access_token'
  end
  constraints(Spree::StaticPage) do
    get '/(*path)', :to => 'static_content#show', :as => 'static'
  end
end
