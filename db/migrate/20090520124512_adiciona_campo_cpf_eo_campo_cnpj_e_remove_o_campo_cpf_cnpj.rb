class AdicionaCampoCpfEoCampoCnpjERemoveOCampoCpfCnpj < ActiveRecord::Migration
  def self.up
    add_column :pessoas,:cpf,:string
    add_column :pessoas,:cnpj,:string
    remove_column :pessoas,:cpf_cnpj
  end

  def self.down
    remove_column :pessoas,:cpf
    remove_column :pessoas,:cnpj
    add_column :pessoas,:string,:cpf_cnpj
  end
end
