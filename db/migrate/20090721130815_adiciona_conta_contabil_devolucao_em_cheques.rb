class AdicionaContaContabilDevolucaoEmCheques < ActiveRecord::Migration
  def self.up
    add_column :cheques, :conta_contabil_devolucao_id,:integer
  end

  def self.down
    drop_column :cheques, :conta_contabil_devolucao_id
  end
end
