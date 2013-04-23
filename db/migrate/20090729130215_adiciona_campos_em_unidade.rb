class AdicionaCamposEmUnidade < ActiveRecord::Migration
  def self.up
    add_column :unidades, :email, :string
    add_column :unidades, :fax, :string
  end

  def self.down
    remove_column :unidades, :email
    remove_column :unidades, :fax
  end
end
