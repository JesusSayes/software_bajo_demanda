class Contact < ActiveRecord::Base
  attr_accessible :content, :email, :name, :phone
  validates :email, :email => true
end
