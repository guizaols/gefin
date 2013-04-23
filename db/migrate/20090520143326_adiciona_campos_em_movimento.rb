class AdicionaCamposEmMovimento < ActiveRecord::Migration
  def self.up
    add_column :movimentos, :pessoa_id, :integer
    add_column :movimentos, :unidade_id, :integer
  end

  def self.down
    remove_column :movimentos, :pessoa_id
    remove_column :movimentos, :unidade_id
  end
end
