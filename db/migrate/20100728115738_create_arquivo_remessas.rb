class CreateArquivoRemessas < ActiveRecord::Migration
  def self.up
    create_table :arquivo_remessas do |t|
      t.string :nome
      t.string :nome_arquivo
      t.integer :status
      t.integer :unidade_id
      t.integer :contas_corrente_id
      t.integer :numero_de_registros
      t.datetime :data_geracao
      t.datetime :data_leitura_banco
      t.timestamps
    end
  end

  def self.down
    drop_table :arquivo_remessas
  end
end
