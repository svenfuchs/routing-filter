TestRailsAdapter::Application.routes.draw do
  filter :uuid, :pagination ,:locale, :extension
  match "/" => "tests#index"
  match "/foo/:id" => "tests#show", :as => 'foo'
end
