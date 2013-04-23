class AdicionaCampoSituacaoAntigaEmParcela < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :situacao_antiga, :integer
  end

  def self.down
    remove_column :parcelas, :situacao_antiga
  end
end
