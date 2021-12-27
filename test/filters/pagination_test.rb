require 'test_helper'

class PaginationTest < Minitest::Test
  attr_reader :routes, :params

  def setup
    @routes = draw_routes do
      filter :pagination
      get 'some', :to => 'some#index'
    end
    @params = { :controller => 'some', :action => 'index', :page => '2' }
  end

  test 'recognizes the path some/page/2' do
    assert_equal params, routes.recognize_path('/some/page/2')
  end

  test 'appends the segments /page/:page to the generated path if the passed :page param does not equal 1' do
    assert_generates '/some/page/2', routes.path_for(params)
  end

  test 'does not append anything to the generated path if the passed :page param equals 1' do
    assert_generates '/some', routes.path_for(params.merge(:page => '1'))
  end

  test 'appends the segments /page/:page to the generated path but respects url query params' do
    assert_generates '/some/page/2?foo=bar', routes.path_for(params.merge(:foo => 'bar'))
  end
end
