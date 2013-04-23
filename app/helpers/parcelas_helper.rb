module ParcelasHelper

  def atualiza_view(parcela)
    javascript_tag "atualiza_cabecalho(#{parcela})"
  end

  def parcelas_ordenadas(parcelas)
    parcelas.sort_by {|a| a.numero.nil? ? a.numero_parcela_filha.real.to_f : a.numero.real.to_f}
  end

  def headers(conta)
    if conta.is_a?(RecebimentoDeConta)
      [["Nº", link_to_remote("", :url => { :action => "ordena_parcelas", :controller=>"recebimento_de_contas", :ordem => "numero" }, :html => {:class => "ordenacao desativado", :id => "ordem_numero"})],
        ['Vencimento',  link_to_remote("", :url => { :action => "ordena_parcelas", :controller=>"recebimento_de_contas", :ordem => "vencimento" }, :html => {:class => "ordenacao ativado", :id => "ordem_vencimento"})],
        'Valor', 'Retenção', 'Valor Líquido', 'Pago em', 'Valor Pago', 'Multa', 'Juros', 'Outros', 'Desconto', 'Situação', ""]
    else
      ["Nº", 'Vencimento','Valor', 'Retenção', 'Valor Líquido', 'Pago em', 'Valor Pago', 'Multa', 'Juros', 'Outros', 'Desconto', 'Situação', ""]
    end
  end

  def mostra_campos_da_baixa_por_banco
    "style=\"display:none;\"" unless @parcela.forma_de_pagamento == Parcela::BANCO
  end
  
  def mostra_campos_da_baixa_por_cheque
    "style=\"display:none;\"" unless @parcela.forma_de_pagamento == Parcela::CHEQUE 
  end
  
  def mostra_campos_da_baixa_por_cartao
    "style=\"display:none;\"" unless @parcela.forma_de_pagamento == Parcela::CARTAO
  end

  def verifica_se_recebimento_ou_pagamento
    @conta.is_a?(PagamentoDeConta) ? {:pagamento_de_conta_id => @conta.id} : {:recebimento_de_conta_id => @conta.id}
  end

  def radio_button_para_filtrar_parcelas(situacoes, padrao)
    situacoes.collect do |situacao|
      '<label class="check_boxes_alinhadas" for="filtro_' + situacao.downcase.gsub(" ", "_") + '">' + radio_button_tag(:filtro, situacao.downcase, situacao == padrao, :onclick => 'filtra_parcelas()') + situacao + '</label>'
    end.join + javascript_tag("filtra_parcelas('filtro_todas')")
  end
  
  def seleciona_conta_contabil_caixa(unidade)
    conta_caixa = ContasCorrente.find_by_unidade_id_and_identificador(unidade.id,ContasCorrente::CAIXA)
    unless conta_caixa.blank?
      update_page do |page|
        page << "if ($('parcela_cheques_attributes_0_prazo').value == '#{Cheque::VISTA}'){"
        page << "$('parcela_cheques_attributes_0_conta_contabil_transitoria_nome').value = '#{conta_caixa.conta_contabil.codigo_contabil + " - "+ conta_caixa.conta_contabil.nome  }';  "
        page << "$('parcela_cheques_attributes_0_conta_contabil_transitoria_id').value = '#{conta_caixa.conta_contabil.id}';  "
        page << "$('parcela_cheques_attributes_0_conta_contabil_transitoria_nome').disabled = true;"
        page << "}"
        page << "else{"
        page << "$('parcela_cheques_attributes_0_conta_contabil_transitoria_nome').disabled = false;"
        page << "$('parcela_cheques_attributes_0_conta_contabil_transitoria_id').value = '';"
        page << "$('parcela_cheques_attributes_0_conta_contabil_transitoria_nome').value = '';}"
      end
    else
      update_page do |page|
        page << "alert('Não existe uma conta do tipo caixa cadastrada!')"
      end
    end
  end

  def seleciona_conta_contabil_caixa_resgate(unidade)
    conta_caixa = ContasCorrente.find_by_unidade_id_and_identificador(unidade.id, ContasCorrente::CAIXA)
    unless conta_caixa.blank?
      update_page do |page|
        page << "if ($('cheques_prazo').value == '#{Cheque::VISTA}'){"
        page << "$('cheques_conta_contabil_transitoria_nome').value = '#{conta_caixa.conta_contabil.codigo_contabil + " - "+ conta_caixa.conta_contabil.nome  }';  "
        page << "$('cheques_conta_contabil_transitoria_id').value = '#{conta_caixa.conta_contabil.id}';  "
        page << "$('cheques_conta_contabil_transitoria_nome').disabled = true;"
        page << "}"
        page << "else{"
        page << "$('cheques_conta_contabil_transitoria_nome').disabled = false;"
        page << "$('cheques_conta_contabil_transitoria_id').value = '';"
        page << "$('cheques_conta_contabil_transitoria_nome').value = '';}"
      end
    else
      update_page do |page|
        page << "alert('Não existe uma conta do tipo caixa cadastrada!')"
      end
    end
  end

  def formas_de_pagamento
    @conta.is_a?(RecebimentoDeConta) ? [["Dinheiro", Parcela::DINHEIRO], ["Banco", Parcela::BANCO], ["Cheque", Parcela::CHEQUE], ["Cartão", Parcela::CARTAO]] :
      [["Dinheiro", Parcela::DINHEIRO], ["Banco", Parcela::BANCO]]
  end

  def formas_de_pagamento_resgate
    [["Dinheiro", Parcela::DINHEIRO], ["Cheque", Parcela::CHEQUE], ["Cartão", Parcela::CARTAO]]
  end
  
  def atualiza_valor_dos_juros(data, id_parcela, id_recebimento)
    remote_function(:url => {:controller => 'parcelas', :action => :atualiza_juros}, :with => "'data=' + $('parcela_#{data}').value +  '&id='+ '#{id_parcela}' + '&recebimento_de_conta_id='+ '#{id_recebimento}' + '&tipo_de_data=' + '#{data}'")
  end

  def atualiza_valor_da_baixa_parcial(data, id_parcela, id_recebimento)
    remote_function(:url => {:action => :atualiza_valor_baixa_parcial}, :with => "'data=' + $('parcela_#{data}').value +  '&parcela_id='+ '#{id_parcela}' + '&id='+ '#{id_recebimento}' + '&tipo_de_data=' + '#{data}'")
  end

  def formatos_para_geracao_de_boleto
    options_for_select ['pdf', 'jpg', 'tiff', 'png']
  end
end
