class Feed < ApplicationRecord
  belongs_to :node
  validates(:title, presence: true)
  validates(:feed_type, presence: true)

  def validate
    if !xml_url.present? && !html_url.present?
      errors.add("Either 'xml_url' or 'html_url' must be set for a feed node")
    end
  end
end
