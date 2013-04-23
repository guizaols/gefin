class AdicionaDataDevolucaoEmCheque < ActiveRecord::Migration
  def self.up
    add_column :cheques, :data_devolucao, :datetime
    add_column :cheques, :data_abandono, :datetime
  end

  def self.down
    remove_column :cheques, :data_devolucao
    remove_column :cheques, :data_abandono
  end
end
