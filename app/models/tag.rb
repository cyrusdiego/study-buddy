class Tag < ApplicationRecord
  has_many :content_tags
  has_many :contents, through: :content_tags
end
