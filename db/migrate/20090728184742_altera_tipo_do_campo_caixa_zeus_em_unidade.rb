class AlteraTipoDoCampoCaixaZeusEmUnidade < ActiveRecord::Migration
  def self.up
    add_column :unidades, :nome_caixa_zeus, :string
    remove_column :unidades, :nome_da_caixa_zeus
  end

  def self.down
    add_column :unidades, :nome_da_caixa_zeus, :integer
    remove_column :unidade, :nome_caixa_zeus
  end
end
