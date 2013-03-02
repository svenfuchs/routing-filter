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

ActionDispatch::Routing::RouteSet.class_eval do
  def filters
    @set.filters if @set
  end

  def add_filters(*names)
    options = names.extract_options!
    names.each { |name| filters.unshift(RoutingFilter.build(name, options)) }
  end

  def generate_with_filtering(options, recall = {})
    # `around_generate` is destructive method and it breaks url. To avoid this, `dup` is required.
    filters.run(:around_generate, options, &lambda{ generate_without_filtering(options, recall).map(&:dup) })
  end
  alias_method_chain :generate, :filtering

  def clear_with_filtering!
    filters.clear if filters
    clear_without_filtering!
  end
  alias_method_chain :clear!, :filtering
end

ActionDispatch::Journey::Routes.class_eval do
  def filters
    @filters || RoutingFilter::Chain.new.tap { |f| @filters = f unless frozen? }
  end
end

require 'routing_filter/adapters/routers/journey'
