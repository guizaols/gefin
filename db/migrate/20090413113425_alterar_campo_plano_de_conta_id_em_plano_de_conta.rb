class AlterarCampoPlanoDeContaIdEmPlanoDeConta < ActiveRecord::Migration
  def self.up
    add_column :contas_correntes, :conta_contabil_id, :integer
    remove_column :contas_correntes, :plano_de_conta_id
  end

  def self.down
    add_column :contas_correntes, :plano_de_conta_id, :integer
    remove_column :contas_correntes, :conta_contabil_id
  end
end
