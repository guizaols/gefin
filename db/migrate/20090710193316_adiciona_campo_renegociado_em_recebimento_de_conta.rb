class AdicionaCampoRenegociadoEmRecebimentoDeConta < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :numero_de_renegociacoes, :integer
  end

  def self.down
    remove_column :recebimento_de_contas, :numero_de_renegociacoes
  end
end
