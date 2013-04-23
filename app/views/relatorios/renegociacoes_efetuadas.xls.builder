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
        xml.Cell{};xml.Cell{};xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      @contas.each do |cobrador,contas_cobrador|

        xml.Row do
          xml.Cell { xml.Data 'Funcionário:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data cobrador, 'ss:Type' => 'String' }
        end
        contas_cobrador.group_by{|conta| conta.servico.descricao}.each do |servico,contas_servico|
          xml.Row do
            xml.Cell { xml.Data 'Entidade:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data contas_servico.first.unidade.entidade.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Unidade:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data contas_servico.first.unidade.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Serviço:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data servico, 'ss:Type' => 'String' }
          end
          contas_servico.each do |conta|

            xml.Row do
              xml.Cell { xml.Data 'Contrato:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.numero_de_controle, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Cliente:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.pessoa.nome, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Parcs:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.numero_de_parcelas, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Dt.Ini:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.data_inicio, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Dt.Fim:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.data_final, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Dia Vcto:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.dia_do_vencimento, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Valor:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(conta.valor_do_documento), 'ss:Type' => 'Number' }
            end

            xml.Row do
              xml.Cell { xml.Data 'N.Ren', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.numero_de_renegociacoes, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Valor', 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(conta.valor_do_documento), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data 'Parcs', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.numero_de_parcelas, 'ss:Type' => 'Number' }
              xml.Cell { xml.Data 'Data', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.created_at.to_date.to_s_br, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Dt.Reg', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.data_venda, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Dt.Ini', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.data_inicio, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Dt.Fim', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.data_final, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Vigência', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.vigencia, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Dt.Abertura', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.data_venda, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Atraso', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 0, 'ss:Type' => 'String' }
            end

            xml.Row do
              xml.Cell { xml.Data 'N.Renego', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Juros', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Multa', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Outros', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Desconto', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Vcto', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Valor Parcela', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Data Rec', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Val.Recebido', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Status', 'ss:Type' => 'String' }
            end

            total_juros = 0
            total_multa = 0
            total_acrescimos = 0
            total_desconto = 0
            total_valor = 0
            total_liquido = 0

            conta.parcelas.each do |parcela|

              xml.Row do
                xml.Cell { xml.Data parcela.conta.numero_de_renegociacoes, 'ss:Type' => 'Number' }
                xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_dos_juros), 'ss:Type' => 'Number' }
                xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_da_multa), 'ss:Type' => 'Number' }
                xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.outros_acrescimos), 'ss:Type' => 'Number' }
                xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_do_desconto), 'ss:Type' => 'Number' }
                xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
                xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type' => 'Number' }
                xml.Cell { xml.Data parcela.data_da_baixa, 'ss:Type' => 'String' }
                xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_liquido), 'ss:Type' => 'Number' }
                xml.Cell { xml.Data parcela.situacao_verbose, 'ss:Type' => 'String' }
              end

              total_juros += parcela.valor_dos_juros
              total_multa += parcela.valor_da_multa
              total_acrescimos += parcela.outros_acrescimos
              total_desconto += parcela.valor_do_desconto
              total_valor += parcela.valor
              total_liquido += parcela.valor_liquido

            end

            xml.Row do
              xml.Cell { xml.Data 'Totais >>>', 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_juros), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_multa), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_acrescimos), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_desconto), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data '', 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_valor), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data '', 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_liquido), 'ss:Type' => 'Number' }
            end
          end
        end
      end
    end
  end
end