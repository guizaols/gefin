class CreateParametroContaValores < ActiveRecord::Migration
  def self.up
    create_table :parametro_conta_valores do |t|
      t.integer :plano_de_conta_id
      t.integer :unidade_id
      t.integer :tipo
      t.integer :ano

      t.timestamps
    end
  end

  def self.down
    drop_table :parametro_conta_valores
  end
end
