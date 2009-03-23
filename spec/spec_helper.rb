$: << File.dirname(__FILE__)
$: << File.dirname(__FILE__) + '/../lib/'
$: << File.dirname(__FILE__) + '/../vendor/rails/actionpack/lib'
$: << File.dirname(__FILE__) + '/../vendor/rails/activesupport/lib'

require 'action_controller'
require 'action_controller/test_process'
require 'active_support/vendor'

require 'routing_filter'
require 'routing_filter/locale'
require 'routing_filter/pagination'

class Site
end

class Section
  def id; 1 end
  alias :to_param :id
  def type; 'Section' end
  def path; 'section' end
end

class Article
  def to_param; 1 end
end

module RoutingFilterHelpers
  def draw_routes(&block)
    set = returning ActionController::Routing::RouteSet.new do |set|
      class << set; def clear!; end; end
      set.draw &block
      silence_warnings{ ActionController::Routing.const_set 'Routes', set }
    end
    set
  end

  def instantiate_controller(params)
    returning ActionController::Base.new do |controller|
      request = ActionController::TestRequest.new
      url = ActionController::UrlRewriter.new(request, params)
      controller.stub!(:request).and_return request
      controller.instance_variable_set :@url, url
      controller
    end
  end

  def should_recognize_path(path, params)
    @set.recognize_path(path, {}).should == params
  end

  def section_path(*args)
    @controller.send :section_path, *args
  end

  def section_article_path(*args)
    @controller.send :section_article_path, *args
  end

  def url_for(*args)
    @controller.send :url_for, *args
  end

  def setup_environment
    RoutingFilter::Locale.default_locale = :en
    RoutingFilter::Locale.locales = [:en,:de,:fi]
    I18n.default_locale = :en
    I18n.locale = :en

    @controller = instantiate_controller :locale => 'de', :id => 1
    @set = draw_routes do |map|
      map.filter 'locale'
      map.filter 'pagination'
      map.section 'sections/:id', :controller => 'sections', :action => "show"
      map.section_article 'sections/:section_id/articles/:id', :controller => 'articles', :action => "show"
    end

    @section_params = {:controller => 'sections', :action => "show", :id => "1"}
    @article_params = {:controller => 'articles', :action => "show", :section_id => "1", :id => "1"}
    @locale_filter = @set.filters.first
    @pagination_filter = @set.filters.last
  end
end