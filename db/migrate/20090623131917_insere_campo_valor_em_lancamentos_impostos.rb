class InsereCampoValorEmLancamentosImpostos < ActiveRecord::Migration
  def self.up
    add_column :lancamento_impostos, :valor, :integer
  end

  def self.down
    remove_column :lancamento_impostos, :valor
  end
end
