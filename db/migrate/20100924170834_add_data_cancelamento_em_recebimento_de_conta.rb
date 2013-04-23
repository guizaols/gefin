class AddDataCancelamentoEmRecebimentoDeConta < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :data_cancelamento, :datetime
  end

  def self.down
    remove_column :recebimento_de_contas, :data_cancelamento
  end
end
