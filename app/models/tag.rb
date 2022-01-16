class Tag < ApplicationRecord
  has_many :content_tags
  has_many :contents, through: :content_tags
  has_many :quiz_tags
  has_many :quizzes, through: :quiz_tags

  def summary
    return self.name
  end
end
