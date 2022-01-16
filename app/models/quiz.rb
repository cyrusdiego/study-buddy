class Quiz < ApplicationRecord
  has_many :quiz_contents
  has_many :quiz_tags
  has_many :tags, through: :quiz_tags
  has_many :contents, through: :quiz_contents
  belongs_to :user
  validate :must_have_one_content_or_tag

  def must_have_one_content_or_tag
    if self.contents.empty? and self.tags.empty?
      errors.add(:quiz, 'You must select at least one piece of content or tag')
    end
  end
end
