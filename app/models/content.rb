class Content < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_contents, dependent: :destroy
  has_many :quizzes, through: :quiz_contents, dependent: :destroy
  has_many :content_tags
  has_many :tags, through: :content_tags
  belongs_to :user
  has_one_attached :file
  validates :file, attached: true, content_type: ['application/pdf'], size: { less_than: 20.megabytes, message: 'is not given between size' }
  validates :title, presence: true

  def summary
    return "#{self.title} (#{self.questions.count} questions)"
  end
end
