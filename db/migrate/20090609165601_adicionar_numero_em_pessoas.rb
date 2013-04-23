class AdicionarNumeroEmPessoas < ActiveRecord::Migration
  def self.up
    add_column :pessoas, :numero, :string, :limit => 10
  end

  def self.down
    remove_column :pessoas, :numero
  end
end
