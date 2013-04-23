xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Contas a Receber Geral - Inadimplência' do
    xml.Table do

      xml.Row do
        xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      total_bruto = 0
      total_corrigido = 0

      # Header
      xml.Row do
        xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor a Receber', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor Corrigido', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Vencimento', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Situação', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Dias em Atraso', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Telefone Cliente', 'ss:Type' => 'String' }
      end

      # Rows
      @parcelas.each do |grupo, parcelas|

        xml.Row do
          xml.Cell { xml.Data 'Entidade:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcelas.first.conta.unidade.entidade.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Unidade:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcelas.first.conta.unidade.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Servico', 'ss:Type' => 'String' }
          xml.Cell { xml.Data grupo, 'ss:Type' => 'String' }
        end

        # Row
        total_grupo = 0
        total_parcelas = 0
        valor_liquido_da_parcela_com_juros_e_multa = []

        parcelas.each do |parcela|

          dias_em_atraso = ((Date.today.to_datetime) - ((parcela.data_vencimento).to_date).to_datetime)
          dias_em_atraso = dias_em_atraso.to_i > 0 ? dias_em_atraso.to_i : 0
          valor_liquido_da_parcela_com_juros_e_multa = Gefin.calcular_juros_e_multas(:vencimento=>parcela.data_vencimento,:data_base=>Date.today,:valor=>parcela.valor,:juros=>parcela.conta.juros_por_atraso,:multa=>parcela.conta.multa_por_atraso)

          telefone = parcela.conta.pessoa.telefone.join(", ") unless parcela.conta.pessoa.telefone.blank?

          xml.Row do
            xml.Cell { xml.Data parcela.conta.pessoa.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_liquido_da_parcela_com_juros_e_multa[2]), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.situacao_verbose, 'ss:Type' => 'String' }
            xml.Cell { xml.Data dias_em_atraso, 'ss:Type' => 'Number' }
            xml.Cell { xml.Data telefone, 'ss:Type' => 'String' }
          end

          total_parcelas += parcela.valor
          total_grupo += valor_liquido_da_parcela_com_juros_e_multa[2]
        end
        total_bruto += total_parcelas
        total_corrigido += total_grupo
        xml.Row do
          xml.Cell { xml.Data 'Total Atividade ...>>', 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_parcelas), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_grupo), 'ss:Type' => 'Number' }
        end

      end

      xml.Row do
        xml.Cell { xml.Data 'Totais ...>>', 'ss:Type' => 'String' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_bruto), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_corrigido), 'ss:Type' => 'Number' }
      end

    end

  end
  
end