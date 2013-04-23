class AdicionaPagamentoDeContaId < ActiveRecord::Migration
  def self.up
    add_column :parcelas,:pagamento_de_conta_id,:integer
  end

  def self.down
    remove_column :parcelas,:pagamento_de_conta_id
  end
end
