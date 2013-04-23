class AddContabilizacaoDaReceitaToRecebimentoDeConta < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :contabilizacao_da_receita, :boolean
  end

  def self.down
    remove_column :recebimento_de_contas, :contabilizacao_da_receita
  end
end
