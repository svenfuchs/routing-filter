class TestsController < ActionController::Base
  def index
    url = url_for(params.to_unsafe_h.merge(:only_path => true).symbolize_keys)
    render :plain => params.merge(:url => url).to_unsafe_h
  end

  def show
    url = foo_path(params.to_unsafe_h.symbolize_keys)
    render :plain => params.merge(:url => url).to_unsafe_h.inspect
  end
end
