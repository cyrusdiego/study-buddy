class Content < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_contents, dependent: :destroy
  has_many :quizzes, through: :quiz_contents, dependent: :destroy
  has_many :content_tags, dependent: :destroy
  has_many :tags, through: :content_tags
  belongs_to :user
  has_one_attached :file
  validates :file, attached: true, content_type: ['application/pdf'], size: { less_than: 3.megabytes, message: 'is not given between size' }
  validates :title, presence: true

  def summary
    return "#{self.title} (#{self.questions.count} #{'question'.pluralize(self.questions.count)})"
  end

  # this is the tag's list setter which will capture
  # params[:customer][:add_phone_numbers] when you submit the form
  def add_tags=(tag_string)
    self.tags = tag_string.split(" ").uniq.map do |tag|
      Tag.new(name: tag)
    end
  end

  # this will display tags in the text_field
  def add_tags
    tags.map { |t| t.name }.join(" ")
  end
end
