class AddUnidadeMaeAndUnidadeMaeIdToUnidades < ActiveRecord::Migration
  def self.up
    add_column :unidades, :unidade_mae_check, :boolean
    add_column :unidades, :unidade_mae_id, :integer
  end

  def self.down
    remove_column :unidades, :unidade_mae_id
    remove_column :unidades, :unidade_mae_check
  end
end
