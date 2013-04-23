class AdicionaSenhaBaixaDrEmConfiguracoes < ActiveRecord::Migration
  def self.up
    add_column :unidades, :senha_baixa_dr, :string, :limit => 20
  end

  def self.down
    remove_column :unidades, :senha_baixa_dr
  end
end
