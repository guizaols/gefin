class AdicionaCamposUnidadeIdNaTabelaUsuarios < ActiveRecord::Migration
  def self.up
    add_column :usuarios,:unidade_id,:integer
  end

  def self.down
    remove_column :usuarios,:unidade_id
  end
end
