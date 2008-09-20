require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'RoutingFilter', 'the Locale filter' do
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

  describe "named route url_helpers" do
    it 'does not change the result when the current locale is the default locale and no page option given' do
      section_path(:id => 1).should == '/sections/1'
    end

    it 'does not change the result when given page option equals 1' do
      section_path(:id => 1, :page => 1).should == '/sections/1'
    end

    it 'appends the pages segments when given page option does not equal 1' do
      section_path(:id => 1, :page => 2).should == '/sections/1/pages/2'
    end

    it 'prepends the current locale when it is not the default locale' do
      I18n.locale = :de
      section_path(:id => 1).should == '/de/sections/1'
    end

    it 'prepends a given locale param when it is not the default locale' do
      I18n.locale = :de
      section_path(:id => 1, :locale => :fi).should == '/fi/sections/1'
    end

    it 'works with both a locale and page option' do
      section_path(:id => 1, :locale => :fi, :page => 2).should == '/fi/sections/1/pages/2'
    end
  end

  describe 'when used with named route url_helper with "optimized" generation blocks' do
    # uses optimization
    it 'does not change the result when the current locale is the default locale and no page option given' do
      section_path(1).should == '/sections/1'
    end

    # uses optimization
    it 'prepends the current locale when it is not the default locale' do
      I18n.locale = :de
      section_path(1).should == '/de/sections/1'
    end

    # does not use optimization
    it 'prepends a given locale param when it is not the default locale' do
      I18n.locale = :de
      section_path(1, :locale => :fi).should == '/fi/sections/1'
    end
    
    # does not use optimization
    it 'does not change the result when given page option equals 1' do
      section_path(1, :page => 1).should == '/sections/1'
    end

    # does not use optimization
    it 'appends the pages segments when given page option does not equal 1' do
      section_path(1, :page => 2).should == '/sections/1/pages/2'
    end

    it 'works with both a locale and page option' do
      section_path(1, :locale => :fi, :page => 2).should == '/fi/sections/1/pages/2'
    end
  end

  describe 'when used with a polymorphic_path' do
    # uses optimization
    it 'does not change the result when the current locale is the default locale and no page option given' do
      section_path(Section.new).should == '/sections/1'
    end

    # uses optimization
    it 'prepends the current locale when it is not the default locale' do
      I18n.locale = :de
      section_path(Section.new).should == '/de/sections/1'
    end

    # does not use optimization
    it 'prepends a given locale param when it is not the default locale' do
      I18n.locale = :de
      section_path(Section.new, :locale => :fi).should == '/fi/sections/1'
    end

    # does not use optimization
    it 'does not change the result when given page option equals 1' do
      section_path(Section.new, :page => 1).should == '/sections/1'
    end

    # does not use optimization
    it 'appends the pages segments when given page option does not equal 1' do
      section_path(Section.new, :page => 2).should == '/sections/1/pages/2'
    end

    it 'works with both a locale and page option' do
      section_path(Section.new, :locale => :fi, :page => 2).should == '/fi/sections/1/pages/2'
    end
  end

  describe 'when used with url_for and an ActivRecord instance' do
    it 'prepends the current locale when it is not the default locale' do
      I18n.locale = :de
      url_for(Section.new).should == 'http://test.host/de/sections/1'
    end
    
    it 'does not change the result when no page option given' do
      url_for(Section.new).should == 'http://test.host/sections/1'
    end

    it 'does not change the result when given page option equals 1' do
      params = @params.update :id => Section.new, :page => 1
      url_for(params).should == 'http://test.host/sections/1'
    end

    it 'appends the pages segments when given page option does not equal 1' do
      params = @params.update :id => Section.new, :page => 2
      url_for(params).should == 'http://test.host/sections/1/pages/2'
    end

    it 'works with both a locale and page option' do
      params = @params.update :id => Section.new, :locale => :fi, :page => 2
      url_for(params).should == 'http://test.host/fi/sections/1/pages/2'
    end
  end
end