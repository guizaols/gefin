class RemoveCamposDeUsuario < ActiveRecord::Migration
  def self.up
    remove_column :usuarios, :name
    remove_column :usuarios, :email
  end

  def self.down
    add_column :usuarios, :name, :string
    add_column :usuarios, :email, :string
  end
end
