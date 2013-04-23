class AddIrrfEOutrosImpostosEmContasPagar < ActiveRecord::Migration
def self.up
    add_column :parcelas, :irrf, :integer
    add_column :parcelas, :outros_impostos, :integer
    add_column :parcelas, :unidade_organizacional_irrf_id, :integer
    add_column :parcelas, :centro_irrf_id, :integer
    add_column :parcelas, :conta_contabil_irrf_id, :integer
    add_column :parcelas, :unidade_organizacional_outros_impostos_id, :integer
    add_column :parcelas, :centro_outros_impostos_id, :integer
    add_column :parcelas, :conta_contabil_outros_impostos_id, :integer
  end

  def self.down
    remove_column :parcelas, :irrf
    remove_column :parcelas, :outros_impostos
    remove_column :parcelas, :unidade_organizacional_irrf_id
    remove_column :parcelas, :centro_irrf_id
    remove_column :parcelas, :conta_contabil_irrf_id
    remove_column :parcelas, :unidade_organizacional_outros_impostos_id
    remove_column :parcelas, :centro_outros_impostos_id
    remove_column :parcelas, :conta_contabil_outros_impostos_id
  end
end
