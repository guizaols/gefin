class AdicionaCamposParaGravarDadosDaEvasao < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :data_registro_evasao, :datetime
    add_column :recebimento_de_contas, :justificativa_evasao, :string
  end

  def self.down
    remove_column :recebimento_de_contas, :data_registro_evasao
    remove_column :recebimento_de_contas, :justificativa_evasao
  end
end
