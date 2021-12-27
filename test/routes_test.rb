require 'test_helper'

class RoutesTest < Minitest::Test
  include RoutingFilter
  class RoutingFilter::Test < Filter
    def around_recognize(path, env, &block)
      'recognized'
    end

    def around_generate(*args, &block)
      yield.tap do |result|
        result.update 'generated'
      end
    end
  end

  attr_reader :routes

  def setup
    @routes = draw_routes do
      filter :test
      get 'some/:id', :to => 'some#show'
    end
  end

  test "routes.filter instantiates and registers a filter" do
    assert routes.filters.first.is_a?(RoutingFilter::Test)
  end

  # test "filter.around_recognize is being called" do
  #   assert_equal 'recognized', routes.recognize_path('/')
  # end

  test "filter.around_generate is being called" do
    assert_equal 'generated', routes.path_for({ controller: 'some', action: 'show', id: 1 })
  end
end
