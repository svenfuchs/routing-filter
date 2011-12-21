# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'test/unit'
require 'bundler/setup'

require 'action_controller'
require 'test_declarative'
require 'routing_filter'

class Test::Unit::TestCase
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
    message ||= ''
    msg = build_message(message, "The generated path <?> did not match <?>", generated_path, expected_path)
    assert_equal(expected_path, generated_path, msg)
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
