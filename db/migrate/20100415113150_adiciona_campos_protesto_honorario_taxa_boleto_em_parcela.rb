class AdicionaCamposProtestoHonorarioTaxaBoletoEmParcela < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :protesto, :integer
    add_column :parcelas, :honorarios, :integer
    add_column :parcelas, :taxa_boleto, :integer
    add_column :parcelas, :unidade_organizacional_protesto_id, :integer
    add_column :parcelas, :centro_protesto_id, :integer
    add_column :parcelas, :conta_contabil_protesto_id, :integer
    add_column :parcelas, :unidade_organizacional_taxa_boleto_id, :integer
    add_column :parcelas, :centro_taxa_boleto_id, :integer
    add_column :parcelas, :conta_contabil_taxa_boleto_id, :integer
    add_column :parcelas, :unidade_organizacional_honorarios_id, :integer
    add_column :parcelas, :centro_honorarios_id, :integer
    add_column :parcelas, :conta_contabil_honorarios_id, :integer
  end

  def self.down
    remove_column :parcelas, :protesto
    remove_column :parcelas, :honorarios
    remove_column :parcelas, :taxa_boleto
    remove_column :parcelas, :unidade_organizacional_protesto_id
    remove_column :parcelas, :centro_protesto_id
    remove_column :parcelas, :conta_contabil_protesto_id
    remove_column :parcelas, :unidade_organizacional_taxa_boleto_id
    remove_column :parcelas, :centro_taxa_boleto_id
    remove_column :parcelas, :conta_contabil_taxa_boleto_id
    remove_column :parcelas, :unidade_organizacional_honorarios_id
    remove_column :parcelas, :centro_honorarios_id
    remove_column :parcelas, :conta_contabil_honorarios_id
  end
end
