class AddCamposToUnidades < ActiveRecord::Migration
 def self.up
    add_column :unidades, :dr_nome, :string
    add_column :unidades, :dr_fax, :string
    add_column :unidades, :dr_telefone, :string
    add_column :unidades, :dr_email, :string
  end

  def self.down
    remove_column :unidades, :dr_nome
    remove_column :unidades, :dr_fax
    remove_column :unidades, :dr_telefone
    remove_column :unidades, :dr_email
  end
end
