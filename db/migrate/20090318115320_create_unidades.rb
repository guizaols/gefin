class CreateUnidades < ActiveRecord::Migration
  def self.up
    create_table :unidades do |t|
      t.integer :entidade_id
      t.string :nome
      t.string :sigla
      t.string :endereco
      t.string :bairro
      t.string :cep
      t.integer :localidade_id
      t.boolean :ativa
      t.date :data_de_referencia
      t.string :telefone
      t.string :fax
      t.integer :nome_da_caixa_zeus
      t.string :cnpj
      t.string :complemento

      t.timestamps
    end
  end

  def self.down
    drop_table :unidades
  end
end
