class AdicionaCampoUnidadeEmConvenio < ActiveRecord::Migration
  def self.up
    add_column :convenios,:unidade_id,:integer
  end

  def self.down
    remove_column :convenios,:unidade_id
  end
end
