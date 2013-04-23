class AddServicoAlgumaVezIniciadoToRecebimentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :servico_alguma_vez_iniciado, :boolean
  end

  def self.down
    remove_column :recebimento_de_contas, :servico_alguma_vez_iniciado
  end
end
