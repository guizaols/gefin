class AdicionaOutrosCamposEmParcelas < ActiveRecord::Migration
  def self.up
    add_column :parcelas,:numero,:integer
    add_column :parcelas,:data_da_baixa,:datetime
    add_column :parcelas,:valor_liquido,:integer
    add_column :parcelas,:valor_da_multa,:integer
    add_column :parcelas,:valor_dos_juros,:integer
    add_column :parcelas,:valor_do_desconto,:integer
    add_column :parcelas,:outros_acrescimos,:integer
    add_column :parcelas,:justificativa_para_outros,:text
    add_column :parcelas,:conta_contabil_multa_id ,:integer
    add_column :parcelas,:unidade_organizacional_multa_id,:integer
    add_column :parcelas,:centro_multa_id,:integer
    add_column :parcelas,:conta_contabil_juros_id,:integer
    add_column :parcelas,:unidade_organizacional_juros_id,:integer
    add_column :parcelas,:centro_juros_id,:integer
    add_column :parcelas,:conta_contabil_outros_id,:integer
    add_column :parcelas,:unidade_organizacional_outros_id,:integer
    add_column :parcelas,:centro_outros_id,:integer
    add_column :parcelas,:conta_contabil_desconto_id,:integer
    add_column :parcelas,:unidade_organizacional_desconto_id,:integer
    add_column :parcelas,:centro_desconto_id,:integer
    add_column :parcelas,:historico,:string
    
  end

  def self.down
    remove_column :parcelas,:numero
    remove_column :parcelas,:data_da_baixa
    remove_column :parcelas,:valor_liquido
    remove_column :parcelas,:valor_da_multa
    remove_column :parcelas,:valor_dos_juros
    remove_column :parcelas,:valor_do_desconto
    remove_column :parcelas,:outros_acrescimos
    remove_column :parcelas,:justificativa_para_outros
    remove_column :parcelas,:conta_contabil_multa_id
    remove_column :parcelas,:unidade_organizacional_multa_id
    remove_column :parcelas,:centro_multa_id
    remove_column :parcelas,:conta_contabil_juros_id
    remove_column :parcelas,:unidade_organizacional_juros_id
    remove_column :parcelas,:centro_juros_id
    remove_column :parcelas,:conta_contabil_outros_id
    remove_column :parcelas,:unidade_organizacional_outros_id
    remove_column :parcelas,:centro_outros_id
    remove_column :parcelas,:conta_contabil_desconto_id
    remove_column :parcelas,:unidade_organizacional_desconto_id
    remove_column :parcelas,:centro_desconto_id
    remove_column :parcelas,:historico
  end
end
