class InsereCampoReciboImpressoNoModelParcela < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :recibo_impresso, :boolean
  end

  def self.down
    remove_column :parcelas, :recibo_impresso
  end
end
