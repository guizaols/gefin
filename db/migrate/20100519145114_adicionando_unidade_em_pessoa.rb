class AdicionandoUnidadeEmPessoa < ActiveRecord::Migration
  def self.up
    add_column :pessoas, :unidade_id, :integer
  end

  def self.down
    remove_column :pessoas, :unidade_id
  end
end
