require File.expand_path('../test_helper', __FILE__)

if ActionPack::VERSION::MAJOR == 3
  require "rails"
  require 'rack/test'

  class Rails3Test < Test::Unit::TestCase
    include ::Rack::Test::Methods

    I18n.available_locales = [:en, :de]

    APP = Class.new(Rails::Application).tap do |app|
      app.config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
      app.config.session_store :cookie_store, :key => "_myapp_session"
      app.config.active_support.deprecation = :log
      app.routes.draw do
        match "/" => "rails3_test/tests#index"
        filter :extension, :locale, :pagination, :uuid
      end
      app.initialize!
    end

    class TestsController < ActionController::Base
      include Rails.application.routes.url_helpers

      def index
        url = url_for(params.merge(:only_path => true))
        render :text => params.merge(:url => url).inspect
      end
    end

    def app
      APP
    end

    def params
      last_response.status == 200 ? eval(last_response.body).symbolize_keys : {}
    end

    test "get to /" do
      get '/'
      assert_nil params[:locale]
      assert_nil params[:page]
      assert_nil params[:uuid]
      assert_equal '/en.html', params[:url]
    end

    test "get to /de" do
      get '/de'
      assert_equal 'de', params[:locale]
      assert_nil params[:page]
      assert_nil params[:uuid]
      assert_equal '/de.html', params[:url]
    end

    test "get to /page/2" do
      get '/page/2'
      assert_nil params[:locale]
      assert_equal 2, params[:page]
      assert_nil params[:uuid]
      assert_equal '/en/page/2.html', params[:url]
    end

    test "get to /:uuid" do
      uuid = 'd00fbbd1-82b6-4c1a-a57d-098d529d6854'
      get "/#{uuid}"
      assert_nil params[:locale]
      assert_nil params[:page]
      assert_equal uuid, params[:uuid]
      assert_equal "/en/#{uuid}.html", params[:url]
    end
  end
end
