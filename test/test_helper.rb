# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'bundler/setup'

require 'test_declarative'
require 'active_support/test_case'
require 'action_controller'
require 'routing_filter'

I18n.locale = :en
I18n.default_locale = :en
I18n.available_locales = %w(de en)

class RoutingFilter::TestCase < ActiveSupport::TestCase
  def teardown
    I18n.locale = :en
    RoutingFilter::Locale.include_default_locale = true
  end

  def draw_routes(&block)
    normalized_block = rails_2? ? lambda { |set| set.instance_eval(&block) } : block
    klass = rails_2? ? ActionController::Routing::RouteSet : ActionDispatch::Routing::RouteSet
    klass.new.tap { |set| set.draw(&normalized_block) }
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
      expected_path = "/#{expected_path}" unless expected_path.first == '/'
    end

    generated_path, extra_keys = generated_path if generated_path.is_a?(Array)
    generated_path << "?#{extra_keys.to_query}" unless extra_keys.blank?
    message = "The generated path %s did not match %s" % [generated_path, expected_path]
    assert_equal(expected_path, generated_path, message)
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

    alias get match
  end
end
