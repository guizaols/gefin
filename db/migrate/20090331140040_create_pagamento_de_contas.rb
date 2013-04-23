class CreatePagamentoDeContas < ActiveRecord::Migration
  def self.up
    create_table :pagamento_de_contas do |t|
      t.string :tipo_de_documento
      t.integer :provisao
      t.integer :rateio
      t.integer :pessoa_id
      t.integer :conta_contabil_pessoa_id
      t.date :data_lancamento
      t.date :data_emissao
      t.float :valor_do_documento
      t.integer :numero_de_parcelas
      t.integer :numero_nota_fiscal
      t.date :primeiro_vencimento
      t.string :historico
      t.integer :conta_contabil_despesa_id
      t.integer :unidade_organizacional_id
      t.integer :centro_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pagamento_de_contas
  end
end
