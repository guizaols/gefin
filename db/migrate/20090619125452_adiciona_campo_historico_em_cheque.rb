class AdicionaCampoHistoricoEmCheque < ActiveRecord::Migration
  def self.up
    add_column :cheques, :historico, :text
  end

  def self.down
    remove_column :cheques, :historico
  end
end
