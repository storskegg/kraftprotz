class RootController < ApplicationController
  def index
    response.headers['Content-Language'] = 'en-US'
  end
end
