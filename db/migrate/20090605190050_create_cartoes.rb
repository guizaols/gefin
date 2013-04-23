class CreateCartoes < ActiveRecord::Migration
  def self.up
    create_table :cartoes do |t|
      t.integer :parcela_id
      t.integer :bandeira
      t.string :numero
      t.string :codigo_de_seguranca
      t.string :validade
      t.datetime :data_de_recebimento
      t.string :nome_do_titular

      t.timestamps
    end
  end

  def self.down
    drop_table :cartoes
  end
end
