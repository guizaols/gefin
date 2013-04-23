class AdicionaCamposEmRecebimentoConta < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :data_primeira_carta, :datetime
    add_column :recebimento_de_contas, :data_segunda_carta, :datetime
    add_column :recebimento_de_contas, :data_terceira_carta, :datetime
  end

  def self.down
    remove_column(:recebimento_de_contas, :data_primeira_carta)
    remove_column(:recebimento_de_contas, :data_segunda_carta)
    remove_column(:recebimento_de_contas, :data_terceira_carta)
  end
end
