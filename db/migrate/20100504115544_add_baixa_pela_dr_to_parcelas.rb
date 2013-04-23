class AddBaixaPelaDrToParcelas < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :baixa_pela_dr, :boolean
  end

  def self.down
    remove_column :parcelas, :baixa_pela_dr
  end
end
