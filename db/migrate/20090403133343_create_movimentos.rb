class CreateMovimentos < ActiveRecord::Migration
  def self.up
    create_table :movimentos do |t|
      t.string :numero_de_controle
      t.string :historico
      t.string :tipo_documento 
      t.date :data_lancamento
      t.string :tipo_lancamento, :limit => 1     
      t.integer :valor_total
            
      t.timestamps
    end
  end

  def self.down
    drop_table :movimentos
  end
end
