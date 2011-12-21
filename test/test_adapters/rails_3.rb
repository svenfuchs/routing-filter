require 'test_helper'

require 'rails/all'
require 'rack/test'

Bundler.require

module TestRailsAdapter
  include ::Rack::Test::Methods

  class Application < Rails::Application
    config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
    config.session_store :cookie_store, :key => "_myapp_session"
    config.active_support.deprecation = :log
    config.i18n.default_locale = :en
    routes.draw do
      match "/" => "rails_test/tests#index"
      match "/foo/:id" => "rails_test/tests#show", :as => 'foo'
      filter :uuid, :pagination ,:locale, :extension
    end
  end

  def app
    ::Rails.application
  end

  def response
    last_response
  end
end

TestRailsAdapter::Application.initialize!
