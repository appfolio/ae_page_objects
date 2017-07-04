class Book < ApplicationRecord
  belongs_to :author
  has_one :index
  accepts_nested_attributes_for :index
  accepts_nested_attributes_for :author

  validates_presence_of :title
end
