require File.expand_path('../test_helper', __FILE__)

include RoutingFilter

class RoutingFilterTest < Test::Unit::TestCase
  class FooFilter < Filter
    attr_reader :name
  
    def initialize(name)
      @name = name
    end
  
    def foo(log, &block)
      log << name
      yield
    end
  end
  
  attr_reader :chain
  
  def setup
    @chain = Chain.new
    @chain << FooFilter.new('first') << FooFilter.new('second')
  end
  
  test "filter.previous is nil for the first filter in the chain" do
    assert_nil chain.first.previous
  end
  
  test "filter.previous returns the previous filter in the chain" do
    assert_equal chain.first, chain.last.previous
  end
  
  test "filter.next is nil for the last filter in the chain" do
    assert_nil chain.last.next
  end
  
  test "filter.next returns the next filter in the chain" do
    assert_equal chain.last, chain.first.next
  end
  
  test "chain.run calls the given method on registered filters in the given order" do
    log = []
    assert_equal %w(first second finalizer), chain.run(:foo, log, &lambda { log << 'finalizer' })
  end
end