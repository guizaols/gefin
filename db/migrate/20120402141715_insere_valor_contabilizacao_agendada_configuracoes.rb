class InsereValorContabilizacaoAgendadaConfiguracoes < ActiveRecord::Migration
  def self.up
    execute 'UPDATE unidades SET contabilizacao_agendada = 1'
  end

  def self.down
    execute 'UPDATE unidades SET contabilizacao_agendada = NULL'
  end
end
