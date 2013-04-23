class AddCampoContabilizacaoAgendadaConfiguracoes < ActiveRecord::Migration
  def self.up
    add_column :unidades, :contabilizacao_agendada, :integer
  end

  def self.down
    remove_column :unidades, :contabilizacao_agendada
  end
end
