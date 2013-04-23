class AdicionaNumeroDeControleNaTabelaPagamentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :pagamento_de_contas,:numero_de_controle,:string
  end

  def self.down
    remove_column :pagamento_de_contas,:numero_de_controle
  end
end
