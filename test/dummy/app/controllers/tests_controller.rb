class TestsController < ActionController::Base
  def index
    url = url_for(params.merge(:only_path => true))
    render :text => params.merge(:url => url).inspect
  end

  def show
    url = foo_path(params)
    render :text => params.merge(:url => url).inspect
  end
end
