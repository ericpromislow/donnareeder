class Feed < ApplicationRecord
  belongs_to :node
  validates(:title, presence: true)
  validates(:feed_type, presence: true)

  def validate
      if !xmlUrl.present? && !htmlUrl.present?
        errors.add("Either 'xmlUrl' or 'htmlUrl' must be set for a feed node")
      end
    end
  end
end
