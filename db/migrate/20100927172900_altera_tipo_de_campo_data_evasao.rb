class AlteraTipoDeCampoDataEvasao < ActiveRecord::Migration
  def self.up
    remove_column :recebimento_de_contas, :data_evasao
    add_column :recebimento_de_contas, :data_evasao, :datetime
  end

  def self.down
    remove_column :recebimento_de_contas, :data_evasao
    add_column :recebimento_de_contas, :data_evasao, :string
  end
end
