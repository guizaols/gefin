class CreateDependentes < ActiveRecord::Migration
  def self.up
    create_table :dependentes do |t|
      t.string :nome
      t.string :nome_do_pai
      t.string :nome_da_mae
      t.integer :codccr
      t.integer :pessoa_id

      t.timestamps
    end
  end

  def self.down
    drop_table :dependentes
  end
end
