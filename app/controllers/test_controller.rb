class TestController < ApplicationController
  def index
    session[:test_key] = "test_value"
    render plain: "Session saved: #{session[:test_key]}"
  end
end
