class AdicionaCampoPrazoEmCheque < ActiveRecord::Migration
  def self.up
    add_column :cheques, :prazo, :integer
  end

  def self.down
    remove_column :cheques, :prazo
  end
end
