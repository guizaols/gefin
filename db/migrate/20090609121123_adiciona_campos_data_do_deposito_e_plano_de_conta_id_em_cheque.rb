class AdicionaCamposDataDoDepositoEPlanoDeContaIdEmCheque < ActiveRecord::Migration
  def self.up
    add_column :cheques, :data_do_deposito, :datetime
    add_column :cheques, :plano_de_conta_id, :integer
  end

  def self.down
    remove_column :cheques, :data_do_deposito
    remove_column :cheques, :plano_de_conta_id
  end
end
