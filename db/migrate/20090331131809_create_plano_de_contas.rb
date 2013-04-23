class CreatePlanoDeContas < ActiveRecord::Migration
  def self.up
    create_table :plano_de_contas do |t|
      t.integer :ano
      t.integer :entidade_id
      t.string :codigo_contabil
      t.string :nome
      t.integer :nivel
      t.integer :ativo
      t.integer :tipo_da_conta
      t.string :codigo_reduzido
      t.timestamps
    end
  end

  def self.down
    drop_table :plano_de_contas
  end
end
