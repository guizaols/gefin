class AddUsuarioRenegociacaoIdToRecebimentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :usuario_renegociacao_id, :integer
  end

  def self.down
    remove_column :recebimento_de_contas, :usuario_renegociacao_id
  end
end
