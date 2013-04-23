class InsereEmPagamentoDeContasParcelasGeradas < ActiveRecord::Migration
  def self.up
    add_column :pagamento_de_contas,:parcelas_geradas,:boolean
  end

  def self.down
    remove_column :pagamento_de_contas,:parcelas_geradas
  end
end
