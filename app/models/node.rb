class Node < ApplicationRecord
  belongs_to :user

  has_ancestry
  validates(:node_type, inclusion: { in: %w/node feed/, message: "invalid node_type of %{value}: must be 'node' or 'feed'" })
  validates(:user_id, presence: true)
  validates(:title, presence: true)

  def validate
    if node_type == 'node'
      [:feed_type, :description, :xmlUrl, :htmlUrl].each do |column|
        if self.send(column).present?
          errors.add("Column #{column} shouldn't be set in a node-type node")
        end
      end
    else
      errors.add("missing feed_type") if !feed_type.present?
      if !xmlUrl.present? && !htmlUrl.present?
        errors.add("Either 'xmlUrl' or 'htmlUrl'must be set for a feed node")
      end
    end
  end
end
