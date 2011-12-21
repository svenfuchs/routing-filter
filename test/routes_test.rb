require 'test_helper'

class RoutesTest < Test::Unit::TestCase
  include RoutingFilter
  class RoutingFilter::Test < Filter
    def around_recognize(path, env, &block)
      'recognized'
    end

    def around_generate(*args, &block)
      'generated'
    end
  end

  attr_reader :routes

  def setup
    @routes = if rails_2? 
                draw_routes { |set| set.filter :test } 
              else 
                draw_routes { filter :test } 
              end
  end

  test "routes.filter instantiates and registers a filter" do
    assert routes.filters.first.is_a?(RoutingFilter::Test)
  end

  # test "filter.around_recognize is being called" do
  #   assert_equal 'recognized', routes.recognize_path('/')
  # end

  test "filter.around_generate is being called" do
    assert_equal 'generated', routes.generate({})
  end
end
