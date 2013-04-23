class AdicionaEntidadeEmVariosModels < ActiveRecord::Migration
  def self.up
    add_column :agencias, :entidade_id, :integer
    add_column :historicos, :entidade_id, :integer
  end

  def self.down
    remove_column :agencias, :entidade_id
    remove_column :historicos, :entidade_id
  end
end
