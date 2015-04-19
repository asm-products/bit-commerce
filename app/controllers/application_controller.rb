class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :product_session

  rescue_from ActiveRecord::RecordNotFound, :with => :close_session

  def product_session
    session[:auth_token] ||= params[:auth_token]
    redirect_to restore_product_access_path unless session[:auth_token] && Product.exists?(auth_token: session[:auth_token])
  end

  protected

  def close_session
    # TODO: handle products and purchases only,
    # otherwise fallback to default behaviour, i.e. 404
    # TODO: user different path for purchases, i.e. restore_purchase_path
    redirect_to restore_product_access_path
  end
end
