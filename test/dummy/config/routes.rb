TestRailsAdapter::Application.routes.draw do
  filter :uuid, :pagination, :locale, :extension
  get "/" => "tests#index"
  get "/foo/:id" => "tests#show", :as => 'foo'
end
