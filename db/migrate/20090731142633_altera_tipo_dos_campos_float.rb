class AlteraTipoDosCamposFloat < ActiveRecord::Migration
  def self.up
    change_column :impostos, :aliquota, :decimal, :precision => 16, :scale => 4
    change_column :recebimento_de_contas, :juros_por_atraso, :decimal, :precision => 16, :scale => 4
    change_column :recebimento_de_contas, :multa_por_atraso, :decimal, :precision => 16, :scale => 4
  end

  def self.down
    change_column :impostos, :aliquota, :float
    change_column :recebimento_de_contas, :juros_por_atraso, :float
    change_column :recebimento_de_contas, :multa_por_atraso, :float
  end
end
