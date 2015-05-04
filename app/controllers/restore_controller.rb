class RestoreController < ApplicationController
  skip_before_filter :product_session

  def product_access
  end
end
