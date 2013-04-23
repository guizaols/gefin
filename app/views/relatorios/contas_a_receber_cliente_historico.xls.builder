xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'HISTÓRICO DO CLIENTE' do
    xml.Table do

      xml.Row do
        xml.Cell{};xml.Cell{};xml.Cell{};xml.Cell{};xml.Cell{}
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      # Header
      xml.Row do
        xml.Cell { xml.Data 'Vencimento', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor da Parcela', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data de Recebimento', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor Recebido', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Multa', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Juros', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Hono.', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Protesto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Desconto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Tx. Boleto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Outros', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor Corrigido', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Numero de Controle', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Dias em Atraso', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Dt. Evas./Cancel.', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Situação', 'ss:Type' => 'String' }
      end

      # Rows
      total_geral_parcela = 0
      total_geral_valor = 0
      total_geral_multa = 0
      total_geral_juros = 0
      total_geral_desconto = 0
      total_geral_honorarios = 0
      total_geral_protesto = 0
      total_geral_taxa_boleto = 0
      total_geral_outros = 0
      total_geral_corrigido = 0

      @parcelas.group_by{|parcela| parcela.conta.pessoa.fisica? ? parcela.conta.pessoa.nome : parcela.conta.pessoa.razao_social}.each_pair do |cliente, parcelas|
        xml.Row do
          xml.Cell { xml.Data 'Cliente:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data cliente, 'ss:Type' => 'String' }
        end
        parcelas.group_by{|parcela| parcela.conta}.each_pair do |conta, parcelas|
          total_parcela = 0
          total_valor = 0
          total_multa = 0
          total_juros = 0
          total_desconto = 0
          total_outros = 0
          total_honorarios = 0
          total_protesto = 0
          total_taxa_boleto = 0
          total_corrigido = 0

          xml.Row do
            xml.Cell { xml.Data 'Data da Venda:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.data_venda, 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Unidade:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.unidade.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Serviço:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.servico.descricao, 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Situação da Conta:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.situacao_verbose, 'ss:Type' => 'String' }
          end

          # Row
          parcelas.each do |parcela|
            total_parcela += parcela.valor unless parcela.valor.blank?
            total_valor += parcela.valor_liquido unless parcela.valor_liquido.blank?
            total_multa += parcela.valor_da_multa unless parcela.valor_da_multa.blank?
            total_juros += parcela.valor_dos_juros unless parcela.valor_dos_juros.blank?
            total_desconto += parcela.valor_do_desconto unless parcela.valor_do_desconto.blank?
            total_outros += parcela.outros_acrescimos unless parcela.outros_acrescimos.blank?
            total_honorarios += parcela.honorarios unless parcela.honorarios.blank?
            total_protesto += parcela.protesto unless parcela.protesto.blank?
            total_taxa_boleto += parcela.taxa_boleto unless parcela.taxa_boleto.blank?
            total_corrigido += parcela.valor_liquido unless parcela.valor_liquido.blank?
            xml.Row do
              xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data parcela.data_do_pagamento, 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_liquido), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_da_multa), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_dos_juros), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.honorarios), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.protesto), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_do_desconto), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.taxa_boleto), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.outros_acrescimos), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_liquido), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data parcela.conta.numero_de_controle, 'ss:Type' => 'String' }
              xml.Cell { xml.Data [Parcela::EVADIDA, Parcela::CANCELADA].include?(parcela.situacao) ? 0 : (parcela.dias_em_atraso > 0 ? parcela.dias_em_atraso : 0), 'ss:Type' => 'String' }
              if parcela.situacao == Parcela::EVADIDA
                xml.Cell { xml.Data conta.data_evasao, 'ss:Type' => 'String' }
              elsif parcela.situacao == Parcela::CANCELADA
                data_cancelamento = conta.movimentos.find_by_tipo_lancamento('D').data_lancamento rescue nil
                xml.Cell { xml.Data data_cancelamento, 'ss:Type' => 'String' }
              else
                xml.Cell{}
              end  
              xml.Cell { xml.Data parcela.baixa_pela_dr ? (parcela.situacao_verbose + ' (baixa DR)') : parcela.situacao_verbose, 'ss:Type' => 'String' }
            end
          end
          xml.Row do
            xml.Cell { xml.Data 'Totais...', 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_parcela), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data '', 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_valor), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_multa), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_juros), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_honorarios), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_protesto), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_desconto), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_taxa_boleto), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_outros), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_corrigido), 'ss:Type' => 'Number' }
            total_geral_parcela += total_parcela
            total_geral_valor += total_valor
            total_geral_multa += total_multa
            total_geral_juros += total_juros
            total_geral_desconto += total_desconto
            total_geral_honorarios += total_honorarios
            total_geral_protesto += total_protesto
            total_geral_taxa_boleto += total_taxa_boleto
            total_geral_outros += total_outros
            total_geral_corrigido += total_corrigido
          end
        end
      end
      xml.Row do
        xml.Cell { xml.Data 'Totais...', 'ss:Type' => 'String' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_parcela), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data '', 'ss:Type' => 'String' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_valor), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_multa), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_juros), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_honorarios), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_protesto), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_desconto), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_taxa_boleto), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_outros), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_corrigido), 'ss:Type' => 'Number' }
      end
    end
  end
end