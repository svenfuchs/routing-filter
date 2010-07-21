require 'action_dispatch'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/hash/reverse_merge'

[ActionDispatch::Routing::Mapper, ActionDispatch::Routing::DeprecatedMapper].each do |mapper|
  mapper.class_eval do
    def filter(*args)
      @set.add_filters(*args)
    end
  end
end

ActionDispatch::Routing::RouteSet.class_eval do
  def filters
    @filters ||= RoutingFilter::Chain.new
  end

  def add_filters(*names)
    options = names.extract_options!
    names.each { |name| filters << RoutingFilter.build(name, options) }
  end

  def recognize_path_with_filtering(path, env = {})
    # path = ::URI.unescape(path) # TODO ... hu?
    filters.run(:around_recognize, path, env, &lambda{ recognize_path_without_filtering(path, env) })
  end
  alias_method_chain :recognize_path, :filtering

  def generate_with_filtering(*args)
    filters.run_reverse(:around_generate, args.first, &lambda{ generate_without_filtering(*args) })
  end
  alias_method_chain :generate, :filtering

  def clear_with_filtering!
    filters.clear
    clear_without_filtering!
  end
  alias_method_chain :clear!, :filtering
end