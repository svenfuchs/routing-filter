ENV['RAILS_ENV'] = 'test'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'test/unit'
require 'action_pack'
require 'active_support'
require 'test_declarative'
require 'routing_filter'

include RoutingFilter

class Test::Unit::TestCase
  def draw_routes(&block)
    ActionDispatch::Routing::RouteSet.new.tap { |set| set.draw(&block) }
  end
end

require 'action_controller'
require 'active_support/core_ext/enumerable.rb'

class SomeController < ActionController::Base
end
