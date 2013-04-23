class AlterarNomeCamposEmAgencias < ActiveRecord::Migration
def self.up
    add_column :agencias, :localidade_id, :integer
    add_column :agencias, :banco_id, :integer
    remove_column :agencias, :localidades_id
    remove_column :agencias, :bancos_id
  end

  def self.down
    add_column :agencias, :localidades_id, :integer
    add_column :agencias, :bancos_id, :integer
    remove_column :agencias, :localidade_id
    remove_column :agencias, :banco_id
  end
end
