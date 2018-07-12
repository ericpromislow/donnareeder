class CreateNodes < ActiveRecord::Migration[5.2]
  def change
    create_table :nodes do |t|
      t.string :node_type
      t.string :feed_type
      t.string :title
      t.string :description
      t.string :xmlUrl
      t.string :htmlUrl
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
