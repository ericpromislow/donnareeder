class CreateNodes < ActiveRecord::Migration[5.2]
  def change
    create_table :nodes do |t|
      t.string :node_type
      t.string :title
      t.integer :position
      t.references :user, foreign_key: true

      t.timestamps
    end
    
    add_column :nodes, :ancestry, :string
    add_index :nodes, :ancestry
  end
end
