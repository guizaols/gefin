class AddLancamentoschequesAndLancamentoscartoesToUnidades < ActiveRecord::Migration
  def self.up
    add_column :unidades, :lancamentoscheques, :integer
    add_column :unidades, :lancamentoscartoes, :integer
  end

  def self.down
    remove_column :unidades, :lancamentoscheques
    remove_column :unidades, :lancamentoscartoes
  end
end
