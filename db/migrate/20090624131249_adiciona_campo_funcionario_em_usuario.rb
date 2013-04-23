class AdicionaCampoFuncionarioEmUsuario < ActiveRecord::Migration
  def self.up
    add_column :usuarios, :funcionario_id, :integer
  end

  def self.down
    remove_column :usuarios, :funcionario_id
  end
end
