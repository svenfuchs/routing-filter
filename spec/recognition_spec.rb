require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'RoutingFilter', 'url recognition' do
  include RoutingFilterHelpers
  
  before :each do
    RoutingFilter::Locale.default_locale = :en
    I18n.default_locale = :en
    I18n.locale = :en

    @controller = instantiate_controller :locale => 'de', :id => 1
    @set = draw_routes do |map|
      map.section 'sections/:id', :controller => 'sections', :action => "show"
      map.user 'users/:id', :controller => 'users', :action => "show"
      map.filter 'locale'
      map.filter 'pagination'
    end
    
    @params = {:controller => 'sections', :action => "show", :id => "1"}
    @locale_filter = @set.filters.first
  end
  
  def should_recognize_path(path, params)
    @set.recognize_path(path, {}).should == params
  end
  
  def section_path(*args)
    @controller.send :section_path, *args
  end
  
  def url_for(*args)
    @controller.send :url_for, *args
  end

  it 'recognizes the path /de/sections/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1', @params.update(:locale => 'de')
  end
  
  it 'recognizes the path /sections/1/pages/1 and sets the :page param' do
    should_recognize_path '/sections/1/pages/1', @params.update(:page => 1)
  end
  
  it 'recognizes the path /de/sections/1/pages/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/pages/1', @params.update(:locale => 'de', :page => 1)
  end

  it 'recognizes the path /de/users/1 and sets the :locale param' do
    should_recognize_path '/de/users/1', @params.update(:locale => 'de', :controller => 'users')
  end
  
  it 'recognizes the path /users/1/pages/1 and sets the :locale param' do
    should_recognize_path '/users/1/pages/1', @params.update(:controller => 'users', :page => 1)
  end
  
  it 'recognizes the path /de/users/1/pages/1 and sets the :locale param' do
    should_recognize_path '/de/users/1/pages/1', @params.update(:locale => 'de', :controller => 'users', :page => 1)
  end
  
  it 'recognizes the path /sections/1 and does not set a :locale param' do
    should_recognize_path '/sections/1', @params
  end
  
  it 'recognizes the path /sections/1 and does not set a :page param' do
    should_recognize_path '/sections/1', @params
  end
  
  it 'recognizes the path /users/1 and does not set a :locale param' do
    should_recognize_path '/users/1', @params.update(:controller => 'users')
  end
  
  it 'recognizes the path /users/1 and does not set a :page param' do
    should_recognize_path '/users/1', @params.update(:controller => 'users')
  end
end