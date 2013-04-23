class AdicionaCampoUnidadeCedente < ActiveRecord::Migration
  def self.up
    add_column :unidades, :nome_cedente, :string
  end

  def self.down
    remove_column :unidades, :nome_cedente
  end
end
