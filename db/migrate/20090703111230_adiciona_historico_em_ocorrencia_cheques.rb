class AdicionaHistoricoEmOcorrenciaCheques < ActiveRecord::Migration
  def self.up
    add_column :ocorrencia_cheques,:historico,:string
  end

  def self.down
    remove_column :ocorrencia_cheques,:historico
  end
end
