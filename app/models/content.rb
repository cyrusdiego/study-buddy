class Content < ApplicationRecord
  has_many :questions
  belongs_to :user
  has_one_attached :file
  validates :file, attached: true, content_type: ['application/pdf'], size: { less_than: 20.megabytes, message: 'is not given between size' }
  validates :title, presence: true
end
