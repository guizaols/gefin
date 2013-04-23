class CreatePessoas < ActiveRecord::Migration
  def self.up
    create_table :pessoas do |t|
      t.string :nome
      t.string :rg_ie
      t.string :cpf_cnpj
      t.boolean :cliente
      t.boolean :funcionario
      t.boolean :fornecedor
      t.string :razao_social
      t.string :contato
      t.integer :tipo_pessoa
      t.string :endereco
      t.string :email
      t.string :telefone
      t.string :conta
      t.string :agencia
      t.string :banco
      t.text :observacoes
      t.boolean :spc

      t.timestamps
    end
  end

  def self.down
    drop_table :pessoas
  end
end
