class AddFieldsForBolletoToUnidades < ActiveRecord::Migration
  def self.up
    add_column :unidades, :agencia, :string
    add_column :unidades, :conta_corrente, :string
    add_column :unidades, :convenio, :string
  end

  def self.down
    remove_column :unidades, :convenio
    remove_column :unidades, :conta_corrente
    remove_column :unidades, :agencia
  end
end
