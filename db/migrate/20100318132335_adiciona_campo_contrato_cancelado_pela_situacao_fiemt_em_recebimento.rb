class AdicionaCampoContratoCanceladoPelaSituacaoFiemtEmRecebimento < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :cancelado_pela_situacao_fiemt, :boolean
  end

  def self.down
    remove_column :recebimento_de_contas, :cancelado_pela_situacao_fiemt
  end
end
