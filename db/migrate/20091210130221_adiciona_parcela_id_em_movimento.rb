class AdicionaParcelaIdEmMovimento < ActiveRecord::Migration
  def self.up
    add_column :movimentos, :parcela_id, :integer
  end

  def self.down
    remove_column :movimentos, :parcela_id
  end
end
