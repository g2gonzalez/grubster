Rails.application.routes.draw do
  #root 'grubsters#index'
  get '/' => 'grubsters#index'
  post '/send_msg' => 'grubsters#send_msg'
end
