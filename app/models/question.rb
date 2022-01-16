class Question < ApplicationRecord
  belongs_to :content
  validates :question, presence: true
end
