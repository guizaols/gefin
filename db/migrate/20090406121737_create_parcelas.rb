class CreateParcelas < ActiveRecord::Migration
  def self.up
    create_table :parcelas do |t|
      t.date :data_vencimento
      t.float :valor

      t.timestamps
    end
  end

  def self.down
    drop_table :parcelas
  end
end
