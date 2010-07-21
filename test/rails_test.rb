require File.expand_path('../test_helper', __FILE__)

class RailsTest < Test::Unit::TestCase
  class RoutingFilter::Test < Base
    def around_recognize(path, env, &block)
      'recognized'
    end

    def around_generate(*args, &block)
      'generated'
    end
  end
  
  attr_reader :routes
  
  def setup
    @routes = draw_routes { filter :test }
  end

  def draw_routes(&block)
    ActionDispatch::Routing::RouteSet.new.tap { |set| set.draw(&block) }
  end

  test "routes.filter instantiates and registers a filter" do
    assert routes.filters.first.is_a?(RoutingFilter::Test)
  end
  
  test "filter.around_recognize is being called" do
    assert_equal 'recognized', routes.recognize_path('/')
  end
  
  test "filter.around_generate is being called" do
    assert_equal 'generated', routes.generate
  end
end