class AdicionaRelacionamentoPolimorficoEmMovimento < ActiveRecord::Migration
  def self.up
    add_column :movimentos, :conta_id, :integer
    add_column :movimentos, :conta_type, :string

  end

  def self.down
    remove_column :movimentos, :conta_id
    remove_column :movimentos, :conta_type
  end
end
