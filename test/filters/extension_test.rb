require 'test_helper'

class ForceExtensionTest < Minitest::Test
  attr_reader :routes, :params

  def setup
    @routes = draw_routes do
      filter :extension, :exclude => %r(^/(admin|$))
      get '/',                  :to => 'some#index'
      get 'some/:id(.:format)', :to => 'some#show'
      get '/admin/some/new',    :to => 'some#new'
    end
    @params = { :controller => 'some', :action => 'show', :id => '1' }
  end

  test 'recognizes the path some/1.html and strips the extension' do
    assert_nil routes.recognize_path('/some/1.html')[:format]
  end

  test 'recognizes the path some/1.xml but does not strip the extension' do
    assert 'xml', routes.recognize_path('/some/1.xml')[:format]
  end

  test 'appends the extension .html to the generated path' do
    assert_generates '/some/1.html', routes.path_for(params)
  end

  test 'does not touch existing extensions in generated paths' do
    assert_generates '/some/1.xml', routes.path_for(params.merge(:format => 'xml'))
  end

  test 'does not touch url query params in generated paths' do
    assert_generates '/some/1.html?foo=bar', routes.path_for(params.merge(:foo => 'bar'))
  end

  test 'excludes / by default' do
    assert_generates '/', routes.path_for(:controller => 'some', :action => 'index')
  end

  test 'excludes / by default (with url query params)' do
    assert_generates '/?foo=bar', routes.path_for(:controller => 'some', :action => 'index', :foo => 'bar')
  end

  test 'excludes with custom regexp' do
    assert_generates '/admin/some/new', routes.path_for(:controller => 'some', :action => 'new')
  end

  # TODO - why would anyone want to have this?
  #
  # test 'does not exclude / when :exclude => false was passed' do
  #   routes.filters.first.instance_variable_set(:@exclude, false)
  #   assert_generates '/.html', routes.generate(:controller => 'some', :action => 'index')
  # end
end
