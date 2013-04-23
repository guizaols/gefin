class CreateItensMovimentos < ActiveRecord::Migration
  def self.up
    create_table :itens_movimentos do |t|
      t.integer :movimento_id
      t.integer :plano_de_conta_id
      t.integer :unidade_organizacional_id
      t.integer :centro_id
      t.integer :tipo, :limit => 1
      t.integer :valor
            
      t.timestamps
    end
  end

  def self.down
    drop_table :itens_movimentos
  end
end
