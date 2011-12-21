require 'test_helper'

class UuidTest < Test::Unit::TestCase
  attr_reader :routes, :uuid, :params

  def setup
    @routes = draw_routes do
      filter :uuid
      match 'some/:id', :to => 'some#show'
    end
    @uuid   = 'd00fbbd1-82b6-4c1a-a57d-098d529d6854'
    @params = { :controller => 'some', :action => 'show', :id => '1', :uuid => uuid }
  end

  test 'recognizes the path :uuid/product/1' do
    assert_equal params, routes.recognize_path("/#{uuid}/some/1")
  end

  test 'prepends the :uuid segment to the generated path if passed as a param' do
    assert_generates "/#{uuid}/some/1", routes.generate(params)
  end

  test 'matches uuid segments' do
    pattern = Uuid::UUID_SEGMENT
    uuids = %w(
      d00fbbd1-82b6-4c1a-a57d-098d529d6854 cdb33760-94da-11df-981c-0800200c9a66
      0c65a6ec-6491-4316-a137-0021cf4e6471 cbbd44c3-c195-48e5-be04-3cc8a6578f51
    )
    uuids.each { |uuid| assert pattern.match("/#{uuid}/"), "does not match /#{uuid}/ but should" }
  end

  test 'does not match non-uuid segments' do
    pattern = Uuid::UUID_SEGMENT
    uuids = %w(
      !aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa aaaa-aaaaaaaa-aaaa-aaaa-aaaaaaaaaaaa
      aaaaaaaa_aaaa_aaaa_aaaa_aaaaaaaaaaaa aaaaaaaa-aaaa-aaaa-aaaaaaaaaaaa
    )
    uuids.each { |uuid| assert !pattern.match("/#{uuid}/"), "matches /#{uuid}/ but shouldn't" }
  end
end
