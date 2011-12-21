module TestRailsAdapter
  module RackTestHelper
    include Rack::Test::Methods

    def response
      last_response
    end

    def app
      TestRailsAdapter::Application
    end
  end
end

require File.expand_path("../../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
