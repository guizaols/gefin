class AtualizaSituacoesFiemtQueJaExistem < ActiveRecord::Migration
  def self.up
    execute "UPDATE recebimento_de_contas SET situacao_fiemt = 1 WHERE situacao_fiemt IS NULL"
  end

  def self.down
    execute "UPDATE recebimento_de_contas SET situacao_fiemt = NULL"
  end
end
