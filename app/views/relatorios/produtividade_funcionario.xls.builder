xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Geral do Contas a Receber' do
    xml.Table do

      xml.Row do
        xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      xml.Row do
        xml.Cell { xml.Data 'Contrato', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor Recebido', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Recebido Em', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor Parcelado', 'ss:Type' => 'String' }
      end

      # Row
      @parcelas.each do |cobrador,parcelas_cobrador|

        total_relatorio = 0
        total_liquido_relatorio = 0

        xml.Row do
          xml.Cell { xml.Data 'Funcionário:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data cobrador, 'ss:Type' => 'String' }
        end

        # Row
        parcelas_cobrador.group_by{|conta| conta.conta.servico.descricao}.each do |servico,parcelas_servico|

          xml.Row do
            xml.Cell { xml.Data 'Entidade:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcelas_servico.first.conta.unidade.entidade.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Unidade:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcelas_servico.first.conta.unidade.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Serviço:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data servico, 'ss:Type' => 'String' }
          end
          total = 0
          total_liquido = 0

          parcelas_servico.each do |parcela|
            xml.Row do
              xml.Cell { xml.Data parcela.conta.numero_de_controle, 'ss:Type' => 'String' }
              xml.Cell { xml.Data parcela.conta.pessoa.nome, 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data parcela.data_da_baixa, 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_liquido), 'ss:Type' => 'Number' }
            end

            total += parcela.valor
            total_liquido += parcela.valor_liquido
            total_relatorio += parcela.valor
            total_liquido_relatorio += parcela.valor_liquido

          end

          xml.Row do
            xml.Cell { xml.Data 'Totais >>>', 'ss:Type' => 'String' }
            xml.Cell { xml.Data '', 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data '', 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_liquido), 'ss:Type' => 'Number' }
          end
        end
        xml.Row do
          xml.Cell { xml.Data 'Totais >>>', 'ss:Type' => 'String' }
          xml.Cell { xml.Data '', 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_relatorio), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data '', 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_liquido_relatorio), 'ss:Type' => 'Number' }
        end

      end

    end

  end

end