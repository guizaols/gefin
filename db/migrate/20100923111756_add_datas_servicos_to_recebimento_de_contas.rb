class AddDatasServicosToRecebimentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :data_inicio_servico, :datetime
    add_column :recebimento_de_contas, :data_final_servico, :datetime
    add_column :recebimento_de_contas, :valor_original, :integer
    add_column :recebimento_de_contas, :servico_iniciado, :boolean
  end

  def self.down
    remove_column :recebimento_de_contas, :data_inicio_servico
    remove_column :recebimento_de_contas, :data_final_servico
    remove_column :recebimento_de_contas, :valor_original
    remove_column :recebimento_de_contas, :servico_iniciado
  end
end
