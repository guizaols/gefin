class AdicionaCamposNaTabelaMovimentos < ActiveRecord::Migration
  def self.up
    add_column :movimentos, :numero_da_parcela, :integer
    add_column :movimentos, :provisao, :integer
  end

  def self.down
    remove_column :movimentos, :numero_da_parcela
    remove_column :movimentos, :provisao
  end
end
