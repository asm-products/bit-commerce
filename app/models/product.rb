class Product < ActiveRecord::Base
  has_many :purchases
end
