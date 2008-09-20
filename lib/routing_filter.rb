module RoutingFilter
  mattr_accessor :active
  @@active = true
  
  class << self
    def around_recognition(route, path, env)
      return route.recognize_path_without_filtering(path, env) unless RoutingFilter.active
      path = path.dup
      chain = [lambda{ route.recognize_path_without_filtering(path, env) }]
      ActionController::Routing::Routes.filters.each do |filter|
        chain.unshift lambda{
          filter.around_recognition(route, path, env, &chain.shift)
        }
      end
      chain.shift.call
    end
  
    def around_generation(controller, *args)
      return controller.url_for_without_filtering(*args) unless RoutingFilter.active
      chain = [lambda{ controller.url_for_without_filtering(*args) }]
      ActionController::Routing::Routes.filters.each do |filter|
        chain.unshift lambda{
          filter.around_generation(controller, *args, &chain.shift)
        }
      end
      chain.shift.call *args
    end
  
    def around_generation_optimized(controller, result, *args)
      return result unless RoutingFilter.active
      chain = [lambda{ result }]
      ActionController::Routing::Routes.filters.each do |filter|
        chain.unshift lambda{
          filter.around_generation(controller, *args, &chain.shift)
        }
      end
      chain.shift.call
    end
  end
end

# allows to install a filter to the route set by calling: map.filter 'locale'
ActionController::Routing::RouteSet::Mapper.class_eval do
  def filter(name, options = {})
    require "routing_filter/#{name}"
    klass = RoutingFilter.const_get name.to_s.camelize
    # klass = "RoutingFilter::#{name.to_s.camelize}".constantize
    @set.filters.push klass.new(options)
  end
end

# hook into url_for and call before and after filters
ActionController::Base.class_eval do
  def url_for_with_filtering(*args)
    RoutingFilter.around_generation(self, *args)
  end
  alias_method_chain :url_for, :filtering
end

# same here for the optimized url generation in named routes
ActionController::Routing::RouteSet::NamedRouteCollection.class_eval do
  # gosh. monkey engineering optimization code
  def generate_optimisation_block_with_filtering(*args)
    code = generate_optimisation_block_without_filtering *args
    if match = code.match(%r(^return (.*) if (.*)))
      <<-code
        if #{match[2]}
          result = #{match[1]}
          RoutingFilter.around_generation_optimized self, result, *args
          return result
        end
      code
    end
  end
  alias_method_chain :generate_optimisation_block, :filtering
end

ActionController::Routing::RouteSet.class_eval do
  # allow to register filters to the route set
  def filters
    @filters ||= []
  end

  # wrap recognition filters around recognize_path
  def recognize_path_with_filtering(path, env)
    RoutingFilter.around_recognition(self, path, env)
  end
  alias_method_chain :recognize_path, :filtering

  # add some useful information to the request environment
  # right, this is from jamis buck's excellent article about routes internals
  # http://weblog.jamisbuck.org/2006/10/26/monkey-patching-rails-extending-routes-2
  # TODO move this ... where?
  alias_method :extract_request_environment_without_host, :extract_request_environment unless method_defined? :extract_request_environment_without_host
  def extract_request_environment(request)
    returning extract_request_environment_without_host(request) do |env|
      env.merge! :host => request.host,
                 :port => request.port,
                 :host_with_port => request.host_with_port,
                 :domain => request.domain,
                 :subdomain => request.subdomains.first
    end
  end
end