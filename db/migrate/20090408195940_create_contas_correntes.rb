class CreateContasCorrentes < ActiveRecord::Migration
  def self.up
    create_table :contas_correntes do |t|
      t.integer :unidade_id
      t.integer :agencia_id
      t.string :numero_conta
      t.string :digito_verificador
      t.string :descricao
      t.boolean :ativo
      t.integer :identificador
      t.datetime :data_abertura
      t.datetime :data_encerramento
      t.integer :saldo_inicial
      t.integer :saldo_atual
      t.integer :tipo

      t.timestamps
    end
  end

  def self.down
    drop_table :contas_correntes
  end
end
