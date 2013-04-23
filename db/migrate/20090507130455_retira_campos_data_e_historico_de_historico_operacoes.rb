class RetiraCamposDataEHistoricoDeHistoricoOperacoes < ActiveRecord::Migration
  def self.up
    remove_column :historico_operacoes, :historico
    remove_column :historico_operacoes, :data
  end

  def self.down
    add_column :historico_operacoes, :historico, :text
    add_column :historico_operacoes, :data, :datetime
  end
end
