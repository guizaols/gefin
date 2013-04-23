class CreateConvenios < ActiveRecord::Migration
  def self.up
    create_table :convenios do |t|
      t.string :numero
      t.string :tipo_de_servico
      t.integer :quantidade_de_trasmissao

      t.timestamps
    end
  end

  def self.down
    drop_table :convenios
  end
end
