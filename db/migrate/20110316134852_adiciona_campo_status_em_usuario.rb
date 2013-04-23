class AdicionaCampoStatusEmUsuario < ActiveRecord::Migration
  def self.up
    add_column :usuarios, :status, :integer
  end

  def self.down
    remove_column :usuarios, :status
  end
end
