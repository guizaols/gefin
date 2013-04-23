class AdicionaCampoGestorEmPessoas < ActiveRecord::Migration
  def self.up
  	add_column :pessoas,:liberado_por,:string
  end

  def self.down
  	remove_column :pessoas,:liberado_por
  end
end
