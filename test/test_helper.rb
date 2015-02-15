# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'bundler/setup'

require 'action_controller'
require 'routing_filter'

require 'minitest/autorun'
require 'test_declarative'

I18n.enforce_available_locales = false

module GenerateFix
  def generate(options, recall = {})
    super(options.delete(:use_route), options, recall)
  end
end

class MiniTest::Test
  def draw_routes(&block)
    instance = ActionDispatch::Routing::RouteSet.new.tap { |set| set.draw(&block) }
    instance.extend(GenerateFix)
    instance
  end

  def assert_generates(expected_path, generated_path)
    if expected_path =~ %r{://}
      begin
        uri = URI.parse(expected_path)
        expected_path = uri.path.to_s.empty? ? "/" : uri.path
      rescue URI::InvalidURIError => e
        raise ActionController::RoutingError, e.message
      end
    else
      expected_path = "/#{expected_path}" unless expected_path.start_with?('/')
    end

    generated_path, extra_keys = generated_path if generated_path.is_a?(Array)
    generated_path << "?#{extra_keys.to_query}" unless extra_keys.blank?
    message ||= ''
    msg = "The generated path #{generated_path} did not match #{expected_path}"
    assert_equal(expected_path, generated_path, msg)
  end
end
