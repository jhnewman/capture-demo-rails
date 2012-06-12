Oauthtest::Application.routes.draw do

  match "/:action", :controller => "demo"
  match "/:name/:action", :controller => "demo"


  get "demo/profile"

  get "demo/login"

  get "demo/logout"

  get "demo/authCallback"

  get "demo/home"

  get "demo/edit_profile"

  get "demo/xdcomm"

  get "demo/change_password"

  get "demo/backplane"

  get "demo/sso"

  get "demo/settings"

  get "demo/bar"

  get "demo/foo"

  get "demo/viewsession"

end
