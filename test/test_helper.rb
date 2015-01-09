# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'action_controller'

require 'minitest/autorun'
require 'bundler/setup'

require 'test_declarative'
require 'routing_filter'

module GenerateFix
  def generate(options, recall = {})
    super(options.delete(:use_route), options, recall)
  end
end

class MiniTest::Unit::TestCase
  def draw_routes(&block)
    normalized_block = rails_2? ? lambda { |set| set.instance_eval(&block) } : block
    klass = rails_2? ? ActionController::Routing::RouteSet : ActionDispatch::Routing::RouteSet
    instance = klass.new.tap { |set| set.draw(&normalized_block) }
    instance.extend(GenerateFix) if rails_4_2?
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

  def rails_2?
    ActionPack::VERSION::MAJOR == 2
  end

  def rails_4_2?
    ActionPack::VERSION::MAJOR == 4 && ActionPack::VERSION::MINOR >= 2
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
