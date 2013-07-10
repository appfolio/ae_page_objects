class Book < ActiveRecord::Base
  belongs_to :author
  has_one :index
  accepts_nested_attributes_for :index
  accepts_nested_attributes_for :author
end
