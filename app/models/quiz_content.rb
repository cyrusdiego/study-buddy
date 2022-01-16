class QuizContent < ApplicationRecord
  belongs_to :content
  belongs_to :quiz
end
