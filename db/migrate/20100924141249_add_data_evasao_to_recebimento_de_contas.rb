class AddDataEvasaoToRecebimentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :data_evasao, :string
  end

  def self.down
    remove_column :recebimento_de_contas, :data_evasao
  end
end
