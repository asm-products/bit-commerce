class Purchase < ActiveRecord::Base
  belongs_to :product
  has_secure_token :token
  validates :email, presence: true

  def to_param
    token
  end
end
