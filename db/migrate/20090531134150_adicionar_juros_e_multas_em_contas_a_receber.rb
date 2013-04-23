class AdicionarJurosEMultasEmContasAReceber < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :juros_por_atraso, :float
    add_column :recebimento_de_contas, :multa_por_atraso, :float
    execute 'UPDATE recebimento_de_contas SET juros_por_atraso = 1, multa_por_atraso = 2'
  end

  def self.down
    remove_column :recebimento_de_contas, :juros_por_atraso
    remove_column :recebimento_de_contas, :multa_por_atraso
  end
end
