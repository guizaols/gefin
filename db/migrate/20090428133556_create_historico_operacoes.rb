class CreateHistoricoOperacoes < ActiveRecord::Migration
  def self.up
    create_table :historico_operacoes do |t|
      t.datetime :data
      t.string :descricao
      t.integer :usuario_id
      t.integer :numero_carta_cobranca
      t.text :historico

      t.references :conta, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :historico_operacoes
  end
end
