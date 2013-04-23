class AddDataReversaoRecebimentos < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :data_reversao, :datetime
  end

  def self.down
    remove_column :recebimento_de_contas, :data_reversao
  end
end
