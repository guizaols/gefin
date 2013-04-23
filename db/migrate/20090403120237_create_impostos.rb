class CreateImpostos < ActiveRecord::Migration
  def self.up
    create_table :impostos do |t|
      t.integer :entidade_id
      t.string :descricao
      t.string :sigla
      t.float :aliquota
      t.integer :tipo
      t.integer :classificacao
      t.integer :conta_debito_id
      t.integer :conta_credito_id

      t.timestamps
    end
  end

  def self.down
    drop_table :impostos
  end
end
