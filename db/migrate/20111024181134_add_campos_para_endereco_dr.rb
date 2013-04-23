class AddCamposParaEnderecoDr < ActiveRecord::Migration
 def self.up
    add_column :unidades, :dr_endereco, :string
    add_column :unidades, :dr_complemento, :string
    add_column :unidades, :dr_bairro, :string
    add_column :unidades, :dr_cep, :string
    add_column :unidades, :dr_localidade, :string
    add_column :unidades, :dr_uf, :string
    execute "UPDATE unidades SET dr_endereco = 'PREENCHER', dr_complemento = 'PREENCHER', dr_bairro = 'PREENCHER', dr_cep = 'PREENCHER', dr_localidade = 'PREENCHER', dr_uf = 'PREENCHER'"
  end

  def self.down
    remove_column :unidades, :dr_endereco
    remove_column :unidades, :dr_complemento
    remove_column :unidades, :dr_bairro
    remove_column :unidades, :dr_cep
    remove_column :unidades, :dr_localidade
    remove_column :unidades, :dr_uf
  end
end
