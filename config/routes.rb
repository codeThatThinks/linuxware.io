Rails.application.routes.draw do
  resources :distros do
    resources :repos, shallow: true
    resources :debian_repos, controller: "repos", type: "DebianRepo", shallow: true, path: "repos"
    resources :debian_source_repos, controller: "repos", type: "DebianSourceRepo", shallow: true, path: "repos"
  end

  get "repos/:id/fetch", to: "repos#fetch", as: :fetch_repo
  get "repos/:id/fetch_status", to: "repos#fetch_status", as: :fetch_status_repo
  get "repos/:id/view_fetch", to: "repos#view_fetch", as: :view_fetch_repo
  get "repos/:id/packages/:page_num", to: "repos#show", as: :packages_repo
  get "repos/:id/packages/:page_num/edit", to: "repos#edit_packages", as: :edit_packages_repo
  patch "repos/:id/packages/:page_num", to: "repos#update_packages"
  put "repos/:id/packages/:page_num", to: "repos#update_packages"

  resources :software
  get "software/search/:query", to: "software#search", as: :software_search

  root 'software#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
