require 'action_dispatch'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/hash/reverse_merge'

mappers = [ActionDispatch::Routing::Mapper]
mappers << ActionDispatch::Routing::DeprecatedMapper if defined?(ActionDispatch::Routing::DeprecatedMapper)
mappers.each do |mapper|
  mapper.class_eval do
    def filter(*args)
      @set.add_filters(*args)
    end
  end
end

module ActionDispatchRoutingRouteSetWithFiltering
  def filters
    @set.filters if @set
  end

  def add_filters(*names)
    options = names.extract_options!
    names.each { |name| filters.unshift(RoutingFilter.build(name, options)) }
  end

  def generate(route_key, options, recall = {})
    options = options.symbolize_keys

    # `around_generate` is destructive method and it breaks url. To avoid this, `dup` is required.
    filters.run(:around_generate, options, &lambda{
      super(route_key, options, recall).map(&:dup)
    })
  end

  def clear!
    filters.clear if filters
    super
  end
end

ActionDispatch::Routing::RouteSet.send(:prepend, ActionDispatchRoutingRouteSetWithFiltering)


ActionDispatch::Journey::Routes.class_eval do
  def filters
    @filters ||= RoutingFilter::Chain.new.tap { |f| @filters = f unless frozen? }
  end
end

require 'routing_filter/adapters/routers/journey'
