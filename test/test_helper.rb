ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'bundler/setup'

require 'i18n'
require 'action_pack'
require 'active_support'
require 'action_controller'
require 'active_support/core_ext/enumerable.rb'
require 'test_declarative'
require 'routing_filter'

include RoutingFilter

class SomeController < ActionController::Base
end

class Test::Unit::TestCase
  def draw_routes(&block)
    normalized_block = rails_2? ? lambda { |set| set.instance_eval(&block) } : block
    klass = rails_2? ? ActionController::Routing::RouteSet : ActionDispatch::Routing::RouteSet
    klass.new.tap { |set| set.draw(&normalized_block) }
  end

  def rails_2?
    ActionPack::VERSION::MAJOR == 2
  end
end

if ActionPack::VERSION::MAJOR == 2
  ActionController::Routing::RouteSet::Mapper.class_eval do
    def match(pattern, options)
      pattern.gsub!('(.:format)', '.:format')
      controller, action = options.delete(:to).split('#')
      options.merge!(:controller => controller, :action => action)
      connect(pattern, options)
    end
  end
end
