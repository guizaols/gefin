class CreateCheques < ActiveRecord::Migration
  def self.up
    create_table :cheques do |t|
      t.integer :parcela_id
      t.integer :banco_id
      t.string :agencia
      t.string :conta
      t.string :numero
      t.datetime :data_de_recebimento
      t.datetime :data_para_deposito
      t.string :nome_do_titular

      t.timestamps
    end
  end

  def self.down
    drop_table :cheques
  end
end
