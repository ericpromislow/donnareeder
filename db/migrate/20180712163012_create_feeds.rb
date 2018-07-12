class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds do |t|
      t.string :feed_type
      t.string :title
      t.string :description
      t.string :xmlUrl
      t.string :htmlUrl
      t.references :node, foreign_key: true

      t.timestamps
    end
  end
end
