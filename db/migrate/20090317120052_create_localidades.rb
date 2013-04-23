class CreateLocalidades < ActiveRecord::Migration
  def self.up
    create_table :localidades do |t|
      t.string :nome
      t.string :uf

      t.timestamps
    end
  end

  def self.down
    drop_table :localidades
  end
end
