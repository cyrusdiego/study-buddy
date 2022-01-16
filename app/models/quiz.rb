class Quiz < ApplicationRecord
  has_many :quiz_contents
  has_many :contents, through: :quiz_contents
  belongs_to :user
end