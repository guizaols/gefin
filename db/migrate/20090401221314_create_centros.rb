class CreateCentros < ActiveRecord::Migration
  def self.up
    create_table :centros do |t|
      t.integer :ano
      t.integer :entidade_id
      t.string :codigo_centro
      t.string :nome
      t.string :codigo_reduzido
      t.timestamps
    end
  end

  def self.down
    drop_table :centros
  end
end
