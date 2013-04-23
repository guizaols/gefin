class CriaRelacionamentoPolimorficoEntreParcelaEContas < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :conta_id, :integer
    add_column :parcelas, :conta_type, :string

    execute "UPDATE parcelas SET conta_id = pagamento_de_conta_id, conta_type = 'PagamentoDeConta'"

    remove_column :parcelas, :pagamento_de_conta_id
  end

  def self.down
    add_column :parcelas, :pagamento_de_conta_id, :integer

    execute "UPDATE parcelas SET pagamento_de_conta_id = conta_id"

    remove_column :parcelas, :conta_id
    remove_column :parcelas, :conta_type
  end
end
