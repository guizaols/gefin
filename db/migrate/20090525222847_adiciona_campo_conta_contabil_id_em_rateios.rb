class AdicionaCampoContaContabilIdEmRateios < ActiveRecord::Migration
  def self.up
    add_column :rateios,:conta_contabil_id,:integer
  end

  def self.down
    remove_column :rateios,:conta_contabil_id
  end
end
