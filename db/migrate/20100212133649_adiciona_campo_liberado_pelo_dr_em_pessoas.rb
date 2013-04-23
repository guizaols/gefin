class AdicionaCampoLiberadoPeloDrEmPessoas < ActiveRecord::Migration
  def self.up
    add_column :pessoas, :liberado_pelo_dr, :boolean
  end

  def self.down
    remove_column :pessoas,:liberado_pelo_dr
  end
end
