class CreateLancamentoImpostos < ActiveRecord::Migration
  def self.up
    create_table :lancamento_impostos do |t|
      t.integer :parcela_id
      t.integer :imposto_id
      t.datetime :data_de_recolhimento

      t.timestamps
    end
  end

  def self.down
    drop_table :lancamento_impostos
  end
end
