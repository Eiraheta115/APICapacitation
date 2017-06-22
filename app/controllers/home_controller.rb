class HomeController < ApplicationController
  def index
    render :json => {:messsage => "Hi there! this is Capacitation's API for PSEES project"}
  end
end
