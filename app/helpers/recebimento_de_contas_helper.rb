module RecebimentoDeContasHelper

  def observe_field_para_calcular_data_final(id)
    observe_field id, :url => calcula_data_final_recebimento_de_contas_path, :with => "'vigencia=' + $('recebimento_de_conta_vigencia').value + '&data_inicio=' + $('recebimento_de_conta_data_inicio').value", :loading => "Element.show('loading_data_final')", :complete => "Element.hide('loading_data_final')"
  end

  def parcelas_em_atraso(conta)
    conta.parcelas.find_all{ |parcela| parcela.situacao == Parcela::PENDENTE }.collect{ |parcela| parcela.valor }.sum
  end
end
