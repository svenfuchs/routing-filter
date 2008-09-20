require File.dirname(__FILE__) + '/helper/spec_helper.rb'

describe 'RoutingFilter', 'the Locale filter' do
  include RoutingFilterHelpers
  
  before :each do
    RoutingFilter::Locale.default_locale = :en
    I18n.default_locale = :en

    @controller = instantiate_controller :locale => 'de', :section_id => 1
    @set = draw_routes do |map|
      map.section 'sections/:section_id', :controller => 'sections', :action => "show"
      map.filter 'locale'
    end

    @locale_filter = @set.filters.first
  end

  # it 'recognizes the path /de/sections/1 and sets the :locale param' do
  #   @set.recognize_path('/de/sections/1', {})[:locale].should == 'de'
  # end
  # 
  # it 'recognizes the path /sections/1 and does not set a :locale param' do
  #   @set.recognize_path('/sections/1', {})[:locale].should be_nil
  # end
  # 
  # it 'does not change a generated path when the current locale is the default locale' do
  #   I18n.locale = :en
  #   @controller.send(:section_path, :section_id => 1).should == '/sections/1'
  # end
  # 
  # describe "when used with named route url_helper" do
  #   it 'prepends the current locale to the generated path when it is not the default locale' do
  #     I18n.locale = :de
  #     @controller.send(:section_path, :section_id => 1).should == '/de/sections/1'
  #   end
  # 
  #   it 'prepends a given locale param to the generated path when it is not the default locale' do
  #     I18n.locale = :de
  #     @controller.send(:section_path, :section_id => 1, :locale => :fi).should == '/fi/sections/1'
  #   end
  # end
  
  # describe 'when used with named route url_helper with "optimized" generation blocks' do
  #   it 'prepends the current locale to the generated path when it is not the default locale' do
  #     I18n.locale = :de
  #     @controller.send(:section_path, 1).should == '/de/sections/1'
  #   end
  # 
  #   it 'prepends a given locale param to the generated path when it is not the default locale' do
  #     I18n.locale = :de
  #     @controller.send(:section_path, 1, :locale => :fi).should == '/fi/sections/1'
  #   end
  # end

  # describe 'when used with a polymorphic_path' do
  #   it 'prepends the current locale to the generated path when it is not the default locale' do
  #     I18n.locale = :de
  #     @controller.send(:section_path, Section.new).should == '/de/sections/1'
  #   end
  # 
  #   it 'prepends a given locale param to the generated path when it is not the default locale' do
  #     I18n.locale = :de
  #     @controller.send(:section_path, Section.new, :locale => :fi).should == '/fi/sections/1'
  #   end
  # end
  
  describe 'when used with url_for and an ActivRecord instance' do
    it 'prepends the current locale to the generated path when it is not the default locale' do
      I18n.locale = :de
      @controller.send(:url_for, Section.new).should == 'http://test.host/de/sections/1'
    end
  end
end