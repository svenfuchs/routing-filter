require 'test_helper'

class LocaleTest < Test::Unit::TestCase
  attr_reader :routes, :show_params, :index_params

  def setup
    I18n.locale = nil
    I18n.default_locale = :en
    I18n.available_locales = %w(de en)

    RoutingFilter::Locale.include_default_locale = true

    @index_params = { :controller => 'some', :action => 'index' }
    @show_params  = { :controller => 'some', :action => 'show', :id => '1' }

    @routes = draw_routes do
      filter :locale
      match 'products/:id', :to => 'some#show'
      match '/', :to => 'some#index'
    end
  end

  test 'recognizes the path /en' do
    assert_equal index_params.merge(:locale => 'en'), routes.recognize_path('/en')
  end

  test 'recognizes the path /en/' do
    assert_equal index_params.merge(:locale => 'en'), routes.recognize_path('/en/')
  end

  test 'recognizes the path /en/products/1' do
    assert_equal show_params.merge(:locale => 'en'), routes.recognize_path('/en/products/1')
  end

  test 'recognizes the path /de/products/1' do
    assert_equal show_params.merge(:locale => 'de'), routes.recognize_path('/de/products/1')
  end


  test 'prepends the segments /:locale to the generated path / if the current locale is not the default locale' do
    I18n.locale = 'de'
    assert_generates '/de', routes.generate(index_params)
  end

  test 'prepends the segments /:locale to the generated path /products/1 if the current locale is not the default locale' do
    I18n.locale = 'de'
    assert_generates '/de/products/1', routes.generate(show_params)
  end

  test 'prepends the segments /:locale to the generated path if it was passed as a param' do
    assert_generates '/de/products/1', routes.generate(show_params.merge(:locale => 'de'))
  end

  test 'prepends the segments /:locale if the given locale is the default_locale and include_default_locale is true' do
    assert RoutingFilter::Locale.include_default_locale?
    assert_generates '/en/products/1', routes.generate(show_params.merge(:locale => 'en'))
  end

  test 'does not prepend the segments /:locale if the current locale is the default_locale and include_default_locale is false' do
    I18n.locale = 'en'
    RoutingFilter::Locale.include_default_locale = false
    assert_generates '/products/1', routes.generate(show_params)
  end

  test 'does not prepend the segments /:locale if the given locale is the default_locale and include_default_locale is false' do
    RoutingFilter::Locale.include_default_locale = false
    assert_generates '/products/1', routes.generate(show_params.merge(:locale => I18n.default_locale))
  end
end
