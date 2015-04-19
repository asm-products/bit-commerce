class Purchase < ActiveRecord::Base
  belongs_to :product
  has_secure_token :token

  def to_param
    token
  end
end
