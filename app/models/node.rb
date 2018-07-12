class Node < ApplicationRecord
  belongs_to :user
  has_many :feed
  has_ancestry
  validates(:node_type, inclusion: { in: %w/node feed/, message: "invalid node_type of %{value}: must be 'node' or 'feed'" })
  validates(:title, presence: true)
end
