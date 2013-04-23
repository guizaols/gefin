class AlteracaoTipoDoCampoValorEmParcelas < ActiveRecord::Migration
  def self.up
    remove_column :parcelas,:valor
    add_column :parcelas,:valor,:integer
  end

  def self.down
    add_column :parcelas,:valor,:float
    remove_column :parcelas,:valor
  end
end
