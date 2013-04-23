class AdicionarCamposEmPessoas < ActiveRecord::Migration
  def self.up
    add_column :pessoas,:bairro,:string
    add_column :pessoas,:complemento,:string
    add_column :pessoas,:localidade_id,:integer
    add_column :pessoas,:cep,:string
    add_column :pessoas,:cargo,:string
    add_column :pessoas,:matricula,:string
    add_column :pessoas,:funcionario_ativo,:boolean
    add_column :pessoas,:tipo_da_conta,:string
    
    
  end

  def self.down
    remove_column :pessoas,:bairro
    remove_column :pessoas,:complemento
    remove_column :pessoas,:localidade_id
    remove_column :pessoas,:cep
    remove_column :pessoas,:cargo
    remove_column :pessoas,:matricula
    remove_column :pessoas,:funcionario_ativo
    remove_column :pessoas,:tipo_da_conta
    
  end
end
