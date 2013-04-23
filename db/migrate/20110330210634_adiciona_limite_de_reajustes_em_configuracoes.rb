class AdicionaLimiteDeReajustesEmConfiguracoes < ActiveRecord::Migration
  def self.up
    add_column :unidades, :numero_de_reajustes, :integer
    execute 'UPDATE unidades SET numero_de_reajustes = 1'
  end

  def self.down
    remove_column :unidades, :numero_de_reajustes
    execute 'UPDATE unidades SET numero_de_reajustes = NULL'
  end
end
