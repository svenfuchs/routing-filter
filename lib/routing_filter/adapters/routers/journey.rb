require 'journey/routes'
require 'journey/router'

Journey::Routes.class_eval do
  def filters
    @filters || RoutingFilter::Chain.new.tap { |f| @filters = f unless frozen? }
  end
end

Journey::Router.class_eval do
  def find_routes_with_filtering env
    path, filter_parameters = env['PATH_INFO'], {}

    @routes.filters.run(:around_recognize, path, env) do
      filter_parameters
    end

    find_routes_without_filtering(env).map do |match, parameters, route|
      [ match, parameters.merge(filter_parameters), route ]
    end
  end
  alias_method_chain :find_routes, :filtering
end
