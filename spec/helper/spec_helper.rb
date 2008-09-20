$:.unshift File.dirname(__FILE__) + '/../../vendor/rails'
$:.unshift(File.dirname(__FILE__) + '/../../vendor/rails/activesupport/lib/active_support')

require 'action_controller'
require 'action_controller/test_process'
require 'activesupport/lib/active_support/vendor'

$LOAD_PATH << File.dirname(__FILE__) + '/../../lib/'
require 'routing_filter'
require 'routing_filter/base'
require 'routing_filter/locale'
require File.dirname(__FILE__) + '/mock_filter.rb'

class Section
  def to_param
    1
  end
end

module RoutingFilterHelpers
  def draw_routes(&block)
    set = returning ActionController::Routing::RouteSet.new do |set|
      class << set; def clear!; end; end
      set.draw &block
      silence_warnings{ ActionController::Routing.const_set 'Routes', set }
    end
    set
  end

  def instantiate_controller(params)
    returning ActionController::Base.new do |controller|
      request = ActionController::TestRequest.new
      url = ActionController::UrlRewriter.new(request, params)
      controller.stub!(:request).and_return request
      controller.instance_variable_set :@url, url
      controller
    end
  end
end