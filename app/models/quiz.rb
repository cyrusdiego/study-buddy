class Quiz < ApplicationRecord
  has_many :quiz_contents
  has_many :quiz_tags
  has_many :tags, through: :quiz_tags
  has_many :contents, through: :quiz_contents
  belongs_to :user
  validate :must_have_one_content

  def must_have_one_content
    if self.contents.empty?
      errors.add(:quiz, 'You must select at least one piece of content')
    end
  end
end
