class AdicionaOCampoBancoIdERemoveBanco < ActiveRecord::Migration
  def self.up
    add_column :pessoas,:banco_id,:integer
    remove_column :pessoas,:banco
  end

  def self.down
    add_column :pessoas,:banco,:string
    remove_column :pessoas,:banco_id
  end
end
