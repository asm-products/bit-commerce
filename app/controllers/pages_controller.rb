class PagesController < ApplicationController
  skip_before_filter :product_session, only: [:show]

  def show
  end
end
