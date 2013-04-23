class CriaTabelaReajustes < ActiveRecord::Migration
  def self.up
    create_table 'reajustes', :force => true do |t|
      t.column :valor_reajuste,            :integer
      t.column :data_reajuste,             :datetime
      t.column :conta_id,                  :integer
      t.column :conta_type,                :string, :limit => 40
      t.column :usuario_id,                :integer
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
  end

  def self.down
    drop_table 'reajustes'
  end
end
