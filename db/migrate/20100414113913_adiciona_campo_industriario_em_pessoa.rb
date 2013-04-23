class AdicionaCampoIndustriarioEmPessoa < ActiveRecord::Migration
  def self.up
    add_column :pessoas, :industriario, :boolean
  end

  def self.down
    add_column :pessoas, :industriario, :boolean
  end
end
