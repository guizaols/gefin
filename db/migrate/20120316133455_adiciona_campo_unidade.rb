class AdicionaCampoUnidade < ActiveRecord::Migration
  def self.up
    add_column :unidades, :unidade_organizacional_id, :integer
  end

  def self.down
    remove_column :unidades, :unidade_organizacional_id
  end
end
