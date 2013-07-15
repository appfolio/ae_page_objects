class Index < ActiveRecord::Base
  belongs_to :book
  validates_presence_of :book
end
