class CreateChanges < ActiveRecord::Migration
  def self.up
    create_table :changes do |t|
      t.string :tn
      t.string :msg

      t.timestamps
    end
  end

  def self.down
    drop_table :changes
  end
end
