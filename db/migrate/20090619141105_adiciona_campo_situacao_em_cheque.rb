class AdicionaCampoSituacaoEmCheque < ActiveRecord::Migration
  def self.up
    add_column :cheques, :situacao, :integer
  end

  def self.down
    remove_column :cheques, :situacao
  end
end
