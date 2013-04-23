class AdicionaUnidadeIdEmPagamentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :pagamento_de_contas,:unidade_id,:integer
  end

  def self.down
    remove_column :pagamento_de_contas,:unidade_id
  end
end
