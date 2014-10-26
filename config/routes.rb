Rails.application.routes.draw do
  namespace :sunalytics, defaults: {format: :json}  do
    get 'database_type', :to => 'sunalytics#database_type'
    get 'schema', :to => 'sunalytics#schema'
    get 'scopes(/:model_name)', :to => 'sunalytics#scopes'
    get 'all_scopes', :to => 'sunalytics#all_scopes'
    post 'run_query', :to => 'sunalytics#run_query'
  end
end
