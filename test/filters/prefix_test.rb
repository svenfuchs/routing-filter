require 'test_helper'

class PrefixTest < Minitest::Test
  attr_reader :routes, :show_params, :index_params

  def setup
    RoutingFilter::Prefix.prefixes = %w[prefix]

    @index_params = { controller: 'some', action: 'index' }
    @show_params  = { controller: 'some', action: 'show', id: '1' }

    @routes = draw_routes do
      filter :prefix, exclude: /^\/admin/
      get 'products/:id', to: 'some#show'
      get '/', to: 'some#index'
      get '/admin/products/new', to: 'some#new'
    end

    Thread.current.thread_variable_set('prefix', nil)
  end

  test 'recognizes the path /prefix' do
    assert_equal index_params.merge(prefix: 'prefix'), routes.recognize_path('/prefix')
  end

  test 'recognizes the path /prefix/' do
    assert_equal index_params.merge(prefix: 'prefix'), routes.recognize_path('/prefix/')
  end

  test 'recognizes the path /prefix/products/1' do
    assert_equal show_params.merge(prefix: 'prefix'), routes.recognize_path('/prefix/products/1')
  end

  test 'prepend if prefix exists' do
    routes.recognize_path('/prefix/products/1')

    assert_generates '/prefix/products/1', routes.generate(show_params)
  end

  test 'prepend if prefix not exists' do
    assert_generates '/products/1', routes.generate(show_params)
  end

  test 'excludes with custom regexp' do
    routes.recognize_path('/prefix/products/1')

    assert_generates '/admin/products/new', routes.generate(controller: 'some', action: 'new')
  end
end
