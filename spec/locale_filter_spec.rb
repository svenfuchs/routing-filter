require File.dirname(__FILE__) + '/helper/spec_helper.rb'

describe 'RoutingFilter', 'the Locale filter' do
  include RoutingFilterHelpers
  
  before :each do
    RoutingFilter::Locale.default_locale = :en
    I18n.default_locale = :en
    I18n.locale = :de

    @controller = instantiate_controller :locale => 'de', :id => 1
    @set = draw_routes do |map|
      map.section 'sections/:id', :controller => 'sections', :action => "show"
      map.filter 'locale'
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
  
  it 'recognizes the path /sections/1 and does not set a :locale param' do
    should_recognize_path '/sections/1', @params
  end
  
  describe "named route url_helpers" do
    it 'does not change the result when the current locale is the default locale' do
      I18n.locale = :en
      section_path(:id => 1).should == '/sections/1'
    end
  
    it 'prepends the current locale when it is not the default locale' do
      section_path(:id => 1).should == '/de/sections/1'
    end
  
    it 'prepends a given locale param when it is not the default locale' do
      section_path(:id => 1, :locale => :fi).should == '/fi/sections/1'
    end
  end
  
  describe 'when used with named route url_helper with "optimized" generation blocks' do
    # uses optimization
    it 'does not change the result when the current locale is the default locale' do
      I18n.locale = :en
      section_path(1).should == '/sections/1'
    end
      
    # uses optimization
    it 'prepends the current locale when it is not the default locale' do
      section_path(1).should == '/de/sections/1'
    end
      
    # does not use optimization
    it 'prepends a given locale param when it is not the default locale' do
      section_path(1, :locale => :fi).should == '/fi/sections/1'
    end
  end

  describe 'when used with a polymorphic_path' do
    # uses optimization
    it 'does not change the result when the current locale is the default locale' do
      I18n.locale = :en
      section_path(Section.new).should == '/sections/1'
    end
  
    # uses optimization
    it 'prepends the current locale when it is not the default locale' do
      section_path(Section.new).should == '/de/sections/1'
    end
      
    # does not use optimization
    it 'prepends a given locale param when it is not the default locale' do
      section_path(Section.new, :locale => :fi).should == '/fi/sections/1'
    end
  end
  
  describe 'when used with url_for and an ActivRecord instance' do
    it 'prepends the current locale when it is not the default locale' do
      url_for(Section.new).should == 'http://test.host/de/sections/1'
    end
  end
end