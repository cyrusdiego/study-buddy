class Quiz < ApplicationRecord
  has_many :quiz_contents
  has_many :quiz_tags
  has_many :tags, through: :quiz_tags
  has_many :contents, through: :quiz_contents
  belongs_to :user
end
