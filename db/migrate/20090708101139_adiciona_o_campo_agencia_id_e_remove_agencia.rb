class AdicionaOCampoAgenciaIdERemoveAgencia < ActiveRecord::Migration
  def self.up
    add_column :pessoas,:agencia_id,:integer
    remove_column :pessoas,:agencia
  end

  def self.down
    remove_column :pessoas,:agencia_id
    add_column :pessoas,:agencia,:integer
  end
end
