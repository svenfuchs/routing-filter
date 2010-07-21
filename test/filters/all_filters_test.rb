require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../all_filters/generation', __FILE__)
require File.expand_path('../all_filters/recognition', __FILE__)

class AllFiltersTest < Test::Unit::TestCase
  attr_reader :routes, :params, :uuid

  def setup
    I18n.locale = nil
    I18n.default_locale = :en
    I18n.available_locales = %w(de en)

    RoutingFilter::Locale.include_default_locale = false

    @params = { :controller => 'some', :action => 'index' }
    @uuid   = 'd00fbbd1-82b6-4c1a-a57d-098d529d6854'

    @routes = draw_routes do
      filter :extension, :locale, :pagination, :uuid
      match 'some', :to => 'some#index'
    end
  end
  
  include Recognition, Generation
end