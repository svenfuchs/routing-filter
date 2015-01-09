require 'test_helper'
require 'filters/all_filters/generation'
require 'filters/all_filters/recognition'

class AllFiltersTest < MiniTest::Unit::TestCase
  attr_reader :routes, :params, :uuid

  def setup
    I18n.enforce_available_locales = false
    I18n.locale = nil
    I18n.default_locale = :en
    I18n.available_locales = [:de, :en]

    RoutingFilter::Locale.include_default_locale = false

    @params = { :controller => 'some', :action => 'index' }
    @uuid   = 'd00fbbd1-82b6-4c1a-a57d-098d529d6854'

    @routes = draw_routes do
      filter :uuid, :pagination ,:locale, :extension
      get 'some', :to => 'some#index'
    end
  end

  include Recognition, Generation
end
