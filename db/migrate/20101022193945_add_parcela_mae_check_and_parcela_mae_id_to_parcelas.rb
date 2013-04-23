class AddParcelaMaeCheckAndParcelaMaeIdToParcelas < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :parcela_original_check, :boolean
    add_column :parcelas, :parcela_original_id, :integer
  end

  def self.down
    remove_column :parcelas, :parcela_original_id
    remove_column :parcelas, :parcela_original_check
  end
end
