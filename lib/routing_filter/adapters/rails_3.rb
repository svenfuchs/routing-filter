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

  # def recognize_path_with_filtering(path, env = {})
  #   @set.filters.run(:around_recognize, path.dup, env, &lambda{ recognize_path_without_filtering(path.dup, env) })
  # end
  # alias_method_chain :recognize_path, :filtering

  def generate_with_filtering(options, recall = {}, extras = false)
    filters.run(:around_generate, options, &lambda{ generate_without_filtering(options, recall, extras) })
  end
  alias_method_chain :generate, :filtering

  def clear_with_filtering!
    filters.clear if filters
    clear_without_filtering!
  end
  alias_method_chain :clear!, :filtering
end

case ActionPack::VERSION::MINOR
when 2
  require 'routing_filter/adapters/routers/journey'
when 0,1
  require 'routing_filter/adapters/routers/rack_mount'
end
