class AddMovimentoEmFollowUp < ActiveRecord::Migration
  def self.up
    add_column :historico_operacoes, :movimento_id, :integer
  end

  def self.down
    remove_column :historico_operacoes, :movimento_id
  end
end
