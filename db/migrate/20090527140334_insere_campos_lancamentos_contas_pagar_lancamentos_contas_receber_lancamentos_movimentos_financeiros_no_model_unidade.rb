class InsereCamposLancamentosContasPagarLancamentosContasReceberLancamentosMovimentosFinanceirosNoModelUnidade < ActiveRecord::Migration
 def self.up
    add_column :unidades, :lancamentoscontaspagar, :integer
    add_column :unidades, :lancamentoscontasreceber, :integer
    add_column :unidades, :lancamentosmovimentofinanceiro, :integer
    execute 'UPDATE unidades SET lancamentoscontaspagar = 5, lancamentoscontasreceber = 5, lancamentosmovimentofinanceiro = 5'
  end

  def self.down
    remove_column :unidades, :lancamentoscontaspagar
    remove_column :unidades, :lancamentoscontasreceber
    remove_column :unidades, :lancamentosmovimentofinanceiro
  end
end
