class AddValorToHistoricoOperacao < ActiveRecord::Migration
  def self.up
    add_column :historico_operacoes, :valor, :integer
  end

  def self.down
    remove_column :historico_operacoes, :valor
  end
end
