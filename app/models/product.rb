class Product < ActiveRecord::Base
  has_many :purchases
  has_secure_token :token, :auth_token

  def to_param
    token
  end
end
