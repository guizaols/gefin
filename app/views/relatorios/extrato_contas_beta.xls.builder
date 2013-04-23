xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Contabilizacao Ordem' do

    xml.Table do
      # Row
      xml.Row do
        xml.Cell{}
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end
      conta_corrente = ContasCorrente.find(params[:busca][:conta_corrente_id])
      contador = 1
      xml.Row do
        xml.Cell {xml.Data gera_periodo_relatorio(params[:busca][:data_min], params[:busca][:data_max]), 'ss:Type'=>'String'}
      end
      xml.Row do
        xml.Cell {xml.Data "Resumo da Conta Corrente: #{conta_corrente.resumo}", 'ss:Type'=>'String'}
      end
      xml.Row {}
      xml.Row {}
      @itens_movimentos.group_by {|item_movimento| item_movimento.movimento.data_lancamento }.each do |data, items|
        saldo_anterior = conta_corrente.saldo_anterior(data, session[:unidade_id])
        saldo_dinheiro = 0; saldo_cheque = 0; saldo_atual = 0; entradas = 0; saidas = 0; dinheiro_entrada = 0; dinheiro_saida = 0; cheque_entrada = 0; cheque_saida = 0; parcela = []
        xml.Row do
          xml.Cell {xml.Data "Saldo Inicial em: #{data}", 'ss:Type'=>'String'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_anterior), 'ss:Type'=>'Number'}
        end
        xml.Row do
          xml.Cell {xml.Data 'Item', 'ss:Type'=>'String'}
          xml.Cell {xml.Data 'Número de Controle', 'ss:Type'=>'String'}
          xml.Cell {xml.Data 'Fornecedores/Clientes/Outros', 'ss:Type'=>'String'}
          xml.Cell {xml.Data 'Valor', 'ss:Type'=>'String'}
          xml.Cell {xml.Data 'Saldo', 'ss:Type'=>'String'}
        end
        items.each do |item|
          parcela = item.movimento.conta.parcelas.find_by_id(item.movimento.parcela_id) rescue nil
          item.tipo == "D" ? entradas += item.valor : saidas += item.valor
          saldo_atual = saldo_atual + (item.verifica_valor)
          xml.Row do
            xml.Cell {xml.Data contador, 'ss:Type'=>'Number'}
            xml.Cell {xml.Data item.movimento.numero_de_controle, 'ss:Type'=>'String'}
            xml.Cell {xml.Data item.movimento.pessoa.nome, 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(item.verifica_valor) , 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_atual), 'ss:Type'=>'Number'}
          end
          if (parcela.blank? ? '' : parcela.forma_de_pagamento == Parcela::DINHEIRO) || item.movimento.provisao == Movimento::SIMPLES
            item.tipo == "D" ? dinheiro_entrada += item.valor : dinheiro_saida += item.valor
          elsif parcela.forma_de_pagamento == Parcela::CHEQUE
            item.tipo == "D" ? cheque_entrada += item.valor : cheque_saida += item.valor
          end
          contador += 1
        end
        saldo_cheque = conta_corrente.saldo_anterior(data, session[:unidade_id], Parcela::CHEQUE)
        saldo_dinheiro = saldo_anterior - saldo_cheque
        xml.Row do
          xml.Cell {xml.Data "Resumo em: #{data}", 'ss:Type'=>'String'}
        end
        xml.Row do
          xml.Cell{}
          xml.Cell {xml.Data 'Saldo Inicial', 'ss:Type'=>'String'}
          xml.Cell {xml.Data 'Entradas', 'ss:Type'=>'String'}
          xml.Cell {xml.Data 'Saídas', 'ss:Type'=>'String'}
          xml.Cell {xml.Data 'Saldo Final', 'ss:Type'=>'String'}
        end
        if conta_corrente.identificador == ContasCorrente::CAIXA
          xml.Row do
            xml.Cell {xml.Data 'Dinheiro', 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_dinheiro), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto((dinheiro_entrada)), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto((dinheiro_saida)), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_dinheiro + (dinheiro_entrada - dinheiro_saida)), 'ss:Type'=>'Number'}
          end
          xml.Row do
            xml.Cell {xml.Data 'Cheque à vista', 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_cheque), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto((cheque_entrada)), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto((cheque_saida)), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_cheque + (cheque_entrada - cheque_saida)), 'ss:Type'=>'Number'}
          end
          xml.Row do
            xml.Cell {xml.Data 'Total', 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_anterior), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto((dinheiro_entrada + cheque_entrada)), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto((dinheiro_saida + cheque_saida)), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto((saldo_anterior + (dinheiro_entrada + cheque_entrada) - (dinheiro_saida + cheque_saida))), 'ss:Type'=>'Number'}
          end
        end
        xml.Row do
          xml.Cell {xml.Data 'Total', 'ss:Type'=>'String'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_anterior), 'ss:Type'=>'Number'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(entradas), 'ss:Type'=>'Number'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saidas), 'ss:Type'=>'Number'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_anterior + (entradas - saidas)), 'ss:Type'=>'Number'}
        end
        xml.Row {}
        xml.Row {}
      end
    end
  end
end