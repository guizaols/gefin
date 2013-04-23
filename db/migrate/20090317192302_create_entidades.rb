class CreateEntidades < ActiveRecord::Migration
  def self.up
    create_table :entidades do |t|
      t.string :nome
      t.string :sigla
      t.integer :codigo_zeus

      t.timestamps
    end
  end

  def self.down
    drop_table :entidades
  end
end
