class RemoveOCampoFaxDaTabelaUnidade < ActiveRecord::Migration
  def self.up
    remove_column :unidades,:fax
  end

  def self.down
    add_column :unidade,:fax,:string
  end
end
