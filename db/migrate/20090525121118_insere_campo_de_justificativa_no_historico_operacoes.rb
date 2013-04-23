class InsereCampoDeJustificativaNoHistoricoOperacoes < ActiveRecord::Migration
  def self.up
    add_column :historico_operacoes, :justificativa, :text
  end

  def self.down
    remove_column :historico_operacoes, :justificativa
  end
end
