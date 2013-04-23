class AdicionaCamposNoModelCartao < ActiveRecord::Migration
  def self.up
    add_column :cartoes, :data_do_deposito, :datetime
    add_column :cartoes, :plano_de_conta_id, :integer
    add_column :cartoes, :historico, :text
    add_column :cartoes, :situacao, :integer
  end

  def self.down
    remove_column :cartoes, :data_do_deposito
    remove_column :cartoes, :plano_de_conta_id
    remove_column :cartoes, :historico
    remove_column :cartoes, :situacao
  end
end
