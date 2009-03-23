require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'RoutingFilter', 'url recognition' do
  include RoutingFilterHelpers

  before :each do
    setup_environment
  end

  it 'recognizes the path /de/sections/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1', @section_params.update(:locale => 'de')
  end

  it 'recognizes the path /sections/1/pages/1 and sets the :page param' do
    should_recognize_path '/sections/1/pages/1', @section_params.update(:page => 1)
  end

  it 'recognizes the path /de/sections/1/pages/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/pages/1', @section_params.update(:locale => 'de', :page => 1)
  end

  it 'recognizes the path /sections/1/articles/1 and sets the :locale param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end

  it 'recognizes the path /de/sections/1/articles/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/articles/1', @article_params.update(:locale => 'de')
  end

  it 'recognizes the path /de/sections/1/articles/1/pages/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/articles/1/pages/1', @article_params.update(:locale => 'de', :page => 1)
  end

  it 'recognizes the path /sections/1 and does not set a :locale param' do
    should_recognize_path '/sections/1', @section_params
  end

  it 'recognizes the path /sections/1 and does not set a :page param' do
    should_recognize_path '/sections/1', @section_params
  end

  # Test that routing errors are thrown for invalid locales
  it 'does not recognizes the path /aa/sections/1 and does not set a :locale param' do
    begin
      should_recognize_path '/aa/sections/1', @section_params.update(:locale => 'aa')
      false
    rescue ActionController::RoutingError
      true
    end
  end

  it 'recognizes the path /sections/1/articles/1 and does not set a :locale param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end

  it 'recognizes the path /sections/1/articles/1 and does not set a :page param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end

  # Test that routing errors are thrown for invalid locales
  it 'does not recognize the path /aa/sections/1/articles/1 and does not set a :locale param' do
    begin
      should_recognize_path '/aa/sections/1/articles/1', @article_params.update(:locale => 'aa')
      false
    rescue ActionController::RoutingError
      true
    end
  end
end