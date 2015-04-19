class Product < ActiveRecord::Base
  has_many :purchases
  has_secure_token :token

  def to_param
    token
  end
end
