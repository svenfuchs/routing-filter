require 'test_helper'
require 'rack/test'

# Patches active_support/core_ext/load_error.rb to support 1.9.3 LoadError message
if RUBY_VERSION >= '1.9.3'
  MissingSourceFile::REGEXPS << [/^cannot load such file -- (.+)$/i, 1]
end

require File.expand_path("../../dummy/app/controllers/some_controller.rb",  __FILE__)
require File.expand_path("../../dummy/app/controllers/tests_controller.rb",  __FILE__)

ActionController::Base.session = {
  :key         => '_new_session',
  :secret      => '6e8d9c6ed22fc7c6aba671434701df3ad8c111d92d3c95748915f60382b185b583074f3cebb9aa0d526ca1abef150aac33707a10ca0de70c6889e98f1f2ebe99'
}

module TestRailsAdapter
  module RackTestHelper
    routes = ActionController::Routing::Routes = ActionController::Routing::RouteSet.new
    routes.draw do |map|
      map.connect '/', :controller => 'tests', :action => 'index'
      map.foo '/foo/:id', :controller => 'tests', :action => 'show'
      map.filter :uuid, :pagination ,:locale, :extension
    end

    attr_reader :session
    delegate :get, :response, :to => :session

    def setup
      @session = ActionController::Integration::Session.new(lambda { |env| ActionController::Routing::Routes.call(env) })
    end
  end
end
