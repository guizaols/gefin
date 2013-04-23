class AdicionaCampoSituacaoEmParcela < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :situacao, :integer

    execute "UPDATE parcelas SET situacao = 1 WHERE data_da_baixa IS NULL"
    execute "UPDATE parcelas SET situacao = 2 WHERE data_da_baixa IS NOT NULL"
  end

  def self.down
    remove_column :parcelas, :situacao
  end
end
