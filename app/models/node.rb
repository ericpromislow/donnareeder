class Node < ApplicationRecord
  belongs_to :user
  has_many :feeds
  has_ancestry
  validates(:node_type, inclusion: { in: %w/node feed/, message: "invalid node_type of %{value}: must be 'node' or 'feed'" })
  def validate
    if node_type == 'node' && !title.present?
      errors.add("title is missing")
    end
  end
    
end
