class AdicionarCidadeEmPessoas < ActiveRecord::Migration
  def self.up
    add_column :pessoas,:cidade,:string
  end

  def self.down
    remove_column :pessoas,:cidade
  end
end
