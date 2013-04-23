class CreateAgencias < ActiveRecord::Migration
  def self.up
    create_table :agencias do |t|
      t.string :nome
      t.string :numero
      t.string :digito_verificador
      t.string :endereco
      t.string :bairro
      t.string :complemento
      t.string :telefone
      t.string :fax
      t.string :email
      t.string :nome_contato
      t.string :email_contato
      t.string :telefone_contato
      t.boolean :ativo
      t.integer :localidades_id
      t.integer :bancos_id

      t.timestamps
    end
  end

  def self.down
    drop_table :agencias
  end
end
