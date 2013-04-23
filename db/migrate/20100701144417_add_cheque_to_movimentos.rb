class AddChequeToMovimentos < ActiveRecord::Migration
  def self.up
    add_column :movimentos, :cheque, :boolean
  end

  def self.down
    remove_column :movimentos, :cheque
  end
end
