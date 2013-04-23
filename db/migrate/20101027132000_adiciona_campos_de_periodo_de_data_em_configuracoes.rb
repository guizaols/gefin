class AdicionaCamposDePeriodoDeDataEmConfiguracoes < ActiveRecord::Migration
  def self.up
    add_column :unidades, :data_limite_minima, :datetime
    add_column :unidades, :data_limite_maxima, :datetime
  end

  def self.down
    remove_column :unidades, :data_limite_minima
    remove_column :unidades, :data_limite_maxima
  end
end
