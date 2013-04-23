class CreateCompromissos < ActiveRecord::Migration
  def self.up
    create_table :compromissos do |t|
      t.integer :unidade_id
      t.integer :conta_id
      t.string :conta_type
      t.datetime :data_agendada
      t.text :descricao

      t.timestamps
    end
  end

  def self.down
    drop_table :compromissos
  end
end
