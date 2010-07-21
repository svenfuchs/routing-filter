require File.expand_path('../../test_helper', __FILE__)

class PaginationTest < Test::Unit::TestCase
  attr_reader :routes, :params

  def setup
    @routes = draw_routes do
      filter :pagination
      match 'products/:id', :to => 'some#show'
    end
    @params = { :controller => 'some', :action => 'show', :id => '1', :page => 2 }
  end

  test 'recognizes a path products/1/page/2' do
    assert_equal params, routes.recognize_path('/products/1/page/2')
  end

  test 'appends the segments /page/:page to the generated path if the passed :page param does not equal 1' do
    assert_equal '/products/1/page/2', routes.generate(params)
  end

  test 'does not append anything to the generated path if the passed :page param equals 1' do
    assert_equal '/products/1', routes.generate(params.merge(:page => 1))
  end

  test 'appends the segments /page/:page to the generated path but respects url query params' do
    assert_equal '/products/1/page/2?foo=bar', routes.generate(params.merge(:foo => 'bar'))
  end
end