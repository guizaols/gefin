class AlteraTipoDoCampoTipoEmItensMovimento < ActiveRecord::Migration
  def self.up
    remove_column :itens_movimentos, :tipo
    add_column :itens_movimentos, :tipo, :string, :limit => 1
  end

  def self.down
    add_column :itens_movimentos, :tipo, :string, :limit => 1
    remove_column :itens_movimentos, :tipo
  end
end
