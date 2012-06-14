Oauthtest::Application.routes.draw do
  match "/:action", :controller => "demo"
  match "/:app_name/:screen_name", :controller => "demo", :action => "dispatcher"
end
