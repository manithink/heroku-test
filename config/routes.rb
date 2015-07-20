require 'sidekiq/web'

class MobileWebConstraint
  def self.matches?(request)
    request.subdomain == 'mfarcare' ||request.subdomain != 'www' || request.subdomain == 'm'
  end
end


class WebConstraint
  def self.matches?(request)
    request.subdomain == 'farcare' || request.subdomain == 'www' || request.subdomain.blank?
  end
end


Farcare::Application.routes.draw do
  mount Sidekiq::Web, at: "/sidekiq/yes"
  constraints(WebConstraint) do
    get "home/new"
    get "homes/index"
    post "/get_more_info", to: 'homes#get_more_info', as: "get_more_info"
    get "/:screen_name", to: 'care_giver_companies#new', as: :company_landing
    post "care_giver_companies/:id/login", to: 'care_giver_companies#login', as: :login
    post "care_giver_companies/:id/register", to: "care_giver_companies#create", as: :create
    post '/web/save_signature/:id' => 'mobile/home#mobile_signature', as: :save_web_sign
    devise_for :users, :controllers => {:registrations => 'registrations',
      :sessions => "home", :passwords => "passwords", :confirmations => 'confirmations'}

    # devise_for  :users, :controllers => { :sessions => "home" }
    # devise_for :users, :controllers => { :sessions => "users/sessions" , :registrations => "users/registrations"}
    # The priority is based upon order of creation: first created -> highest priority.
    # See how all your routes lay out with "rake routes".
    # You can have the root of your site routed with "root"
    # devise_scope :user do
    #   root to: 'home#new'
    # end

    root to: 'homes#index', as: 'web_root'
    devise_scope :user do
      get "users/after_activation/:id/:set_password_token", to: "passwords#after_activation", as: :after_activation
      get "users/:id/set_password/:set_password_token", to: "passwords#set_password", as: :set_password
      post "users/:id/update_password/:set_password_token", to: "passwords#update_password", as: :update_password
    end

    namespace :admin do
      resources :home
      get '/settings' => 'home#settings'
      get '/save_settings' => 'home#save_settings'
      post '/upload_settings_images' => 'home#upload_settings_images'
      get '/images/:id/delete' => 'home#delete_admin_images'
    end

    namespace :pcga do
      resources :home

      get '/settings' => 'home#settings'
      patch '/save_settings' => 'home#save_settings'
      post '/upload_settings_images' => 'home#upload_settings_images'
      get '/images/:id/delete' => 'home#delete_admin_images'

      get 'change_status/:id/:status' => 'home#change_status', :as => :change_status
      get ':id/delete' => 'home#delete_company', :as => :delete_company
      get '/assign_care_clients_new' => 'home#assign_care_clients_new', :as => :assign_care_clients_new
      get 'assign_care_clients_new/:id' => 'home#assign_care_clients_create', :as => :assign_care_clients_create
      get 'invite_family' => 'home#invite_family', :as => :invite_family
      post'send_email_invite_family' => 'home#send_email_invite_family', :as => :send_email_invite_family
      patch 'home/:id/edit' => 'home#update', :as => "homes"
      get 'list_services' => 'home#list_services', as: :list_services
      post 'save_category' => 'home#save_category', as: :save_category
      post 'save_services' => 'home#save_services'
      post 'delete_services' => 'home#delete_services'
      post 'delete_category' => 'home#delete_category'
      get 'reports' => 'home#report', as: :report
      post 'get_users' => 'home#get_users'
      # get 'generate_report' => 'home#generate_report', as: :generate_report
      get '/settings/:id/view_profile' => 'home#settings_view_profile', as: :settings_view_profile
      get '/settings/:id/change_password' => 'home#settings_change_password', as: :settings_change_password
      patch '/settings/:id/update_password' => 'home#settings_update_password', as: :settings_update_password
      get '/settings/:id/care_plan_setting' => 'home#care_plan_setting', as: :care_plan_setting
      patch '/settings/:id/update_care_plan_setting' => 'home#update_care_plan_setting', as: :update_care_plan_setting
      get '/settings/(:id)/check_in_out_alerts' => 'home#settings_check_in_out_alerts', as: :settings_check_in_out_alerts
      patch '/settings/:id/update_check_in_out_alerts' => 'home#update_check_in_out_alerts', as: :update_check_in_out_alerts
      post 'get_care_givers/:id' => 'home#get_care_giver', as: "get_care_giver"
      post 'assign_care_giver_to_careclient/:id/:care_client_id' => 'home#assign_care_giver_to_careclient'
      post 'unassign_care_giver_to_careclient/:id/:care_client_id' => 'home#unassign_care_giver_to_careclient'
    end

    namespace :pcg do
      resources :home
      get ':id/delete' => 'home#delete_care_giver', :as => :delete_care_giver
      get 'change_status/:id/:status' => 'home#change_status', :as => :change_status
      get 'view_my_services/:id' => 'home#view_my_services', :as => :view_my_services
      get 'edit_my_services/:id' => 'home#edit_my_services', :as => :edit_my_services
      get 'care_client_services/:id' => 'home#care_client_services', :as => :care_client_services
      post 'save_signature/:id' => 'home#save_signature', :as => :save_signature
      post 'save_service_status/:id' => 'home#save_service_status', as: :save_service_status
      post 'save_comment/:id' => 'home#save_comment', as: :save_comment
      get 'submit_care_service/:id' => 'home#submit_care_service', as: :submit_care_service
      get '/settings/:id/view_profile' => 'home#settings_view_profile', as: :settings_view_profile
      get '/settings/:id/change_password' => 'home#settings_change_password', as: :settings_change_password
      patch '/settings/:id/update_password' => 'home#settings_update_password', as: :settings_update_password
      get '/vacation/:id' => 'vacation_management#index'
      get '/vacation/:id/new_vacation' => 'vacation_management#new_vacation', as: :new_vacation
      post '/vacation/:id/create_vacation' => 'vacation_management#create_vacation', as: :create_vacation
      get '/vacation/:id/get_vacation_details' => 'vacation_management#get_vacation_details', as: :get_vacation_details
      get '/vacation/:id/edit_vacation' => 'vacation_management#edit_vacation', as: :edit_vacation
      post '/vacation/update_vacation/:vacation_id' => 'vacation_management#update_vacation'
      post '/vacation/:event_id/resize_vacation' => 'vacation_management#resize_vacation'
      delete '/vacation/delete_vacation' => 'vacation_management#delete_vacation', as: :delete_vacation
      post '/vacation/:event_id/move_vacation' => 'vacation_management#move_vacation'
      get 'invite_family' => 'home#invite_family', :as => :invite_family
      get '/vacation/:id/current_care_client_events/:care_client_id' => 'vacation_management#current_care_client_events'
      get '/vacation/:id/get_current_care_client_events/:care_client_id' => 'vacation_management#get_current_care_client_events', as: :get_current_care_client_events
    end

    namespace :fcg do
      resources :home
      get 'view_care_clients' => 'home#view_care_clients', as: 'view_care_clients'
      get 'change_status/:id/:status' => 'home#change_status', as: 'change_status'
      get ':id/delete' => 'home#delete_care_client', :as => :delete_care_client
      get '/customize_service_plan/:care_client_id' => 'home#custamise_service_plan', as: :custamise_service_plan
      get '/customize_service_plan' => 'home#custamise_service_plan'
      post '/save_care_client_services' => 'home#save_care_client_services'
      post '/set_surrent_status' => 'home#set_surrent_status'
      get 'view_services/:id' => "home#view_services", as: :view_services
    end
    post  '/pcga/home/get_state_list_pcga', to: 'pcga/home#get_state_list_pcga'
    post  '/pcga/home/get_state_list', to: 'pcga/home#get_state_list'
    post  '/pcg/home/get_state_list', to: 'pcg/home#get_state_list'
  end


  namespace :calendar do
    resources :care_client, :care_giver do
      member do
        get 'index'
        get 'get_services'
        get 'new_service'
        post 'create_service'
        patch 'update_service'
        post 'move_service'
        post 'resize_service'
        get 'assign_pcg_manually'
        post 'create_asigned_event'
        get 'remove_pcg'
        get 'remove_cc'
        get 'auto_assign_pcg'
        get 'manage_vacation_request'
        post 'update_vacation_request'
      end
      collection do
        get 'edit_service'
        delete 'delete_service'
      end
    end
  end

  # For Mobile device
  constraints(MobileWebConstraint) do
    get '/',  to: "mobile/home#new", as: 'mobile_root'
    get '/users/sign_in', to: redirect('/')
    devise_scope :user do
      delete '/users/sign_out' => 'devise/sessions#destroy'
    end
    namespace :mobile do
      resources :home
      post "home/login", to: 'home#login', as: :login
      get "home/settings/:id/change_password", to: 'home#settings_change_password', as: :settings_change_password
      patch "home/settings/:id/update_password", to: 'home#settings_update_password', as: :settings_update_password
      get "home/settings/:id/view_profile", to: 'home#settings_view_profile', as: :settings_view_profile
      patch "home/settings/:id/update_profile", to: 'home#settings_update_profile', as: :settings_update_profile
      get "home/:id/view_care_plan", to: 'home#view_care_plan', as: :view_care_plan
      get "home/:id/view_care_client_services", to: 'home#view_care_client_services', as: :view_care_client_services
      get "home/:id/care_client_detail", to: 'home#care_client_detail', as: :care_client_detail
      post '/save_location/:id' => 'home#save_location', as: :save_location
      post '/save_mobile_signature/:id' => 'home#mobile_signature' , as: :save_mobile_sign
    end
    # post  '/mobile/home/get_state_list', to: 'mobile/home#get_state_list'
    # mapping route to pcg controller
    post '/get_address' => 'pcg/home#get_address' , as: :get_address
    post '/mobile/save_signature/:id' => 'pcg/home#save_signature', as: :mobile_save_signature
    post '/mobile/save_service_status/:id' => 'pcg/home#save_service_status', as: :mobile_save_service_status
    post '/mobile/save_comment/:id' => 'pcg/home#save_comment', as: :mobile_save_comment
    get '/mobile/submit_care_service/:id' => 'pcg/home#submit_care_service', as: :mobile_submit_care_service
    post  '/mobile/home/get_state_list', to: 'application#get_state_list'
    post '/get_company_session_url', to: 'application#get_company_session_url'
  end
end

