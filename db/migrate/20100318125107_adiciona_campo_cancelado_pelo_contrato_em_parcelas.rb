class AdicionaCampoCanceladoPeloContratoEmParcelas < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :cancelado_pelo_contrato, :boolean
  end

  def self.down
    remove_column :parcelas, :cancelado_pelo_contrato
  end
end
