class CreateRateios < ActiveRecord::Migration
  def self.up
    create_table :rateios do |t|
      t.integer :unidade_organizacional_id
      t.integer :centro_id
      t.integer :valor
      t.integer :parcela_id
      t.timestamps
    end
  end

  def self.down
    drop_table :rateios
  end
end
