Rails.application.routes.draw do
  root 'home#index'
  resources :students
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  get  "/evaluations/:module_id" => 'evaluations#getTest'
  post "/evaluate/:evaluation_id" => 'evaluations#getScore'
  
end
