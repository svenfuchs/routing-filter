ENV['RAILS_ENV'] = 'test'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'

# gem 'actionpack', '~> 2.3'

require 'test/unit'
require 'i18n'
require 'action_pack'
require 'active_support'
require 'test_declarative'
require 'routing_filter'

include RoutingFilter

class Test::Unit::TestCase
  def draw_routes(&block)
    klass = ActionPack::VERSION::MAJOR == 2 ? 
      ActionController::Routing::RouteSet : ActionDispatch::Routing::RouteSet
    klass.new.tap { |set| set.draw(&block) }
  end
end

require 'action_controller'
require 'active_support/core_ext/enumerable.rb'

class SomeController < ActionController::Base
end