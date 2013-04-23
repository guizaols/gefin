class CreateCounts < ActiveRecord::Migration
  def self.up
    create_table :counts do |t|
      t.string :tn
      t.integer :number

      t.timestamps
    end

    add_index :counts, :tn
  end

  def self.down
    remove_index :counts, :tn
        
    drop_table :counts
  end
end
