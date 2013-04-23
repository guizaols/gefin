class InsereOCampoAnoNaTabelaPagamentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :pagamento_de_contas,:ano,:integer
  end

  def self.down
    remove_column :pagamento_de_contas,:ano
  end
end
