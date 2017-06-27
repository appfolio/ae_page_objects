class Index < ApplicationRecord
  belongs_to :book
  validates_presence_of :book
end
