class CreateRecebimentoDeContas < ActiveRecord::Migration
  def self.up
    create_table :recebimento_de_contas do |t|
      t.string :tipo_de_documento
      t.string :numero_nota_fiscal
      t.integer :pessoa_id
      t.integer :dependente_id
      t.integer :servico_id
      t.datetime :data_inicio
      t.datetime :data_final
      t.integer :dia_do_vencimento
      t.integer :valor_do_documento
      t.integer :numero_de_parcelas
      t.integer :rateio
      t.string :historico
      t.integer :conta_contabil_receita_id
      t.integer :unidade_organizacional_id
      t.integer :centro_id
      t.datetime :data_venda
      t.integer :origem
      t.integer :vendedor_id
      t.integer :cobrador_id
      t.boolean :parcelas_geradas
      t.integer :situacao
      t.integer :unidade_id
      t.integer :ano
      t.string :numero_de_controle
      t.timestamps
    end
  end

  def self.down
    drop_table :recebimento_de_contas
  end
end
