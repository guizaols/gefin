class AdicionarCampoPlanoDeContaEmContasCorrente < ActiveRecord::Migration
  def self.up
    add_column :contas_correntes, :plano_de_conta_id, :integer
  end

  def self.down
    remove_column :contas_correntes, :plano_de_conta_id
  end
end
