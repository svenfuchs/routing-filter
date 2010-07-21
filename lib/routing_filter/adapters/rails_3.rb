require 'action_dispatch'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/hash/reverse_merge'

[ActionDispatch::Routing::Mapper, ActionDispatch::Routing::DeprecatedMapper].each do |mapper|
  mapper.class_eval do
    def filter(name, options = {})
      @set.filters << RoutingFilter.const_get(name.to_s.camelize).new(options)
    end
  end
end

ActionDispatch::Routing::RouteSet.class_eval do
  def filters
    @filters ||= RoutingFilter::Chain.new
  end

  def recognize_path_with_filtering(path, env = {})
    # path = ::URI.unescape(path) # TODO
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

# TODO move this ... where? do we need it in rails 3 at all?
#
# add some useful information to the request environment
# right, this is from jamis buck's excellent article about routes internals
# http://weblog.jamisbuck.org/2006/10/26/monkey-patching-rails-extending-routes-2
#
# ActionController::Routing::RouteSet.class_eval do
#   alias_method :extract_request_environment_without_host, :extract_request_environment unless method_defined? :extract_request_environment_without_host
#   def extract_request_environment(request)
#     returning extract_request_environment_without_host(request) do |env|
#       env.merge! :host => request.host,
#                  :port => request.port,
#                  :host_with_port => request.host_with_port,
#                  :domain => request.domain,
#                  :subdomain => request.subdomains.first
#     end
#   end
# end
