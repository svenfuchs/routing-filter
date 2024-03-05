module ActionDispatchJourneyRouterWithFiltering
  def find_routes(env)
    path = env.is_a?(Hash) ? env['PATH_INFO'] : env.path_info
    filter_parameters = {}
    original_path = path.dup

    @routes.filters.run(:around_recognize, path, env) do
      filter_parameters
    end

    super(env) do |match, parameters, route|
      parameters = parameters.merge(filter_parameters)

      if env.is_a?(Hash)
        env['PATH_INFO'] = original_path
      else
        env.path_info = original_path
      end

      yield [match, parameters, route]
    end
  end
end

ActionDispatch::Journey::Router.send(:prepend, ActionDispatchJourneyRouterWithFiltering)
