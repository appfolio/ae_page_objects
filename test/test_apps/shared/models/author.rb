class Author < ActiveRecord::Base
  has_many :books
  accepts_nested_attributes_for :books

  SUFFIX_OPTIONS_FOR_SELECT = [
    'Junior',
    'Senior',
    'The third',
    'Esq.'
  ]

end
