class AlteraNomeDoCampoPlanoDeContaIdEmParametroContaValores < ActiveRecord::Migration
  def self.up
    add_column :parametro_conta_valores,:conta_contabil_id,:integer
    remove_column :parametro_conta_valores,:plano_de_conta_id
  end

  def self.down
    remove_column :parametro_conta_valores,:conta_contabil_id
    add_column :parametro_conta_valores,:plano_de_conta_id,:integer
  end
end
