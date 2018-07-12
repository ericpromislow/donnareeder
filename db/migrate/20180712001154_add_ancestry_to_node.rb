class AddAncestryToNode < ActiveRecord::Migration[5.2]
  def change
    add_column :nodes, :ancestry, :string
    add_index :nodes, :ancestry
  end
end
