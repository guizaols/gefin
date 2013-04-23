class AddResponsavelToUnidades < ActiveRecord::Migration
  def self.up
    add_column :unidades, :responsavel, :string
    add_column :unidades, :responsavel_cpf, :string
  end

  def self.down
    remove_column :unidades, :responsavel
    remove_column :unidades, :responsavel_cpf
  end
end
