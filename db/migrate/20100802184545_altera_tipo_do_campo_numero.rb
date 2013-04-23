class AlteraTipoDoCampoNumero < ActiveRecord::Migration
  def self.up
    remove_column :parcelas, :numero
    add_column :parcelas, :numero, :string
  end

  def self.down
    remove_column :parcelas, :numero
    add_column :parcelas, :numero, :integer
  end
end
