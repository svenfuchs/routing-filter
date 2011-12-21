require 'test_helper'
require "test_adapters/rails_#{ActionPack::VERSION::MAJOR}"

class RailsTest < Test::Unit::TestCase
  include TestRailsAdapter::RackTestHelper

  I18n.available_locales = [:en, :de]

  def params
    response.status.to_s.include?('200') ? eval(response.body).symbolize_keys : {}
  end

  test "get to /" do
    get '/'
    assert_nil params[:locale]
    assert_nil params[:page]
    assert_nil params[:uuid]
    assert_equal '/en.html', params[:url]
  end

  test "get to /foo/1" do
    get '/foo/1'
    assert_nil params[:locale]
    assert_nil params[:page]
    assert_nil params[:uuid]
    assert_equal '/en/foo/1.html', params[:url]
  end

  test "get to /de" do
    get '/de'
    assert_equal 'de', params[:locale]
    assert_nil params[:page]
    assert_nil params[:uuid]
    assert_equal '/de.html', params[:url]
  end

  test "get to /de/foo/1" do
    get '/de/foo/1'
    assert_equal 'de', params[:locale]
    assert_nil params[:page]
    assert_nil params[:uuid]
    assert_equal '/de/foo/1.html', params[:url]
  end

  test "get to /page/2" do
    get '/page/2'
    assert_nil params[:locale]
    assert_equal 2, params[:page]
    assert_nil params[:uuid]
    assert_equal '/en/page/2.html', params[:url]
  end

  test "get to /foo/1/page/2" do
    get '/foo/1/page/2'
    assert_nil params[:locale]
    assert_equal 2, params[:page]
    assert_nil params[:uuid]
    assert_equal '/en/foo/1/page/2.html', params[:url]
  end

  test "get to /:uuid" do
    uuid = 'd00fbbd1-82b6-4c1a-a57d-098d529d6854'
    get "/#{uuid}"
    assert_nil params[:locale]
    assert_nil params[:page]
    assert_equal uuid, params[:uuid]
    assert_equal "/en/#{uuid}.html", params[:url]
  end

  test "get to /foo/1/:uuid" do
    uuid = 'd00fbbd1-82b6-4c1a-a57d-098d529d6854'
    get "/#{uuid}/foo/1"
    assert_nil params[:locale]
    assert_nil params[:page]
    assert_equal uuid, params[:uuid]
    assert_equal "/en/#{uuid}/foo/1.html", params[:url]
  end
end
