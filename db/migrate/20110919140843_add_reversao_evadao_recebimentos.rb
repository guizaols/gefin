class AddReversaoEvadaoRecebimentos < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :data_reversao_evasao, :datetime
  end

  def self.down
    remove_column :recebimento_de_contas, :data_reversao_evasao
  end
end
