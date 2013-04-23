class AddRecebimentoDeContaMaeCheckAndRecebimentoDeContaMaeIdToRecebimentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :recebimento_de_conta_mae_check, :boolean
    add_column :recebimento_de_contas, :recebimento_de_conta_mae_id, :integer
  end

  def self.down
    remove_column :recebimento_de_contas, :recebimento_de_conta_mae_id
    remove_column :recebimento_de_contas, :recebimento_de_conta_mae_check
  end
end
