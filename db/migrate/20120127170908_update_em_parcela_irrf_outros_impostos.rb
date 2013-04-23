class UpdateEmParcelaIrrfOutrosImpostos < ActiveRecord::Migration
  def self.up
    execute 'UPDATE parcelas SET irrf = 0, outros_impostos = 0 WHERE irrf IS NULL'
  end

  def self.down
    execute 'UPDATE parcelas SET irrf = NULL, outros_impostos = NULL WHERE irrf = 0'
  end
end
