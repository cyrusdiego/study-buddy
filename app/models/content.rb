class Content < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_contents
  has_many :quizzes, through: :quiz_contents
  belongs_to :user
  has_one_attached :file
  validates :file, attached: true, content_type: ['application/pdf'], size: { less_than: 20.megabytes, message: 'is not given between size' }
  validates :title, presence: true

  def summary
    return "#{self.title} (#{self.questions.count} questions)"
  end
end
