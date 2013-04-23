class AdicionaCampoContaContabilTransitoriaIdEmCheques < ActiveRecord::Migration
  def self.up
    add_column :cheques,:conta_contabil_transitoria_id,:integer
  end

  def self.down
    drop_column :cheques,:conta_contabil_transitoria_id
  end
end
