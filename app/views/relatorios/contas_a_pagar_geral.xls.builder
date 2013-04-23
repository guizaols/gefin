xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Contas a Pagar Geral' do
    xml.Table do

      xml.Row do
        xml.Cell{}; xml.Cell{}; xml.Cell{}; xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      total_geral_liquido = 0
      total_geral_juros = 0
      total_geral_multa = 0
      total_geral_outros = 0
      total_geral_desconto = 0
      total_geral_retencoes = 0
      total_final = 0
      cont = 0
      cont_aux = 0

      xml.Row do
        xml.Cell { xml.Data 'Fornecedor/Cliente', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data Emissão', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Nota Fiscal', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Contrato', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Vencimento', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data Pgto.', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Val. Par.', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Retenção', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Desconto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor Líq.', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Juros', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Multa', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Outros', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Situação', 'ss:Type' => 'String' }
      end

      @parcelas.each do |grupo, parcelas|
        cont_aux += 1
        if cont == 0
          # Row
          xml.Row do
            xml.Cell { xml.Data 'Entidade: ' + parcelas.first.unidade.entidade.nome, 'ss:Type' => 'String' }
            xml.Cell{};
            xml.Cell { xml.Data 'Unidade: ' + parcelas.first.unidade.nome, 'ss:Type' => 'String' }
          end
        end
      
        total_liquido = 0; total_juros = 0; total_multa = 0; total_outros = 0; total_desconto = 0; total_retencoes = 0; total_geral = 0
        parcelas.each do |parcela|
          valores_parcela = 0
          valores_parcela = parcela.valor + parcela.valor_dos_juros + parcela.valor_da_multa + parcela.outros_acrescimos + parcela.valores_novos_recebimentos - parcela.soma_impostos_da_parcela - parcela.valor_do_desconto

          # Row
          xml.Row do
            xml.Cell { xml.Data parcela.conta.pessoa.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.conta.data_emissao, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.conta.numero_nota_fiscal_string, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.conta.numero_de_controle, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.data_da_baixa, 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.soma_impostos_da_parcela), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_do_desconto), 'ss:Type' => 'Number' } if parcela.valor_do_desconto
            xml.Cell { xml.Data valores_parcela > 0 ? preco_formatado_com_decimal_ponto(valores_parcela) : preco_formatado_com_decimal_ponto(0), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_dos_juros), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_da_multa), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.outros_acrescimos), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data parcela.situacao_verbose, 'ss:Type' => 'String' }

            total_geral += parcela.valor
            total_liquido += valores_parcela
            total_retencoes += parcela.soma_impostos_da_parcela
            total_juros += parcela.valor_dos_juros
            total_multa += parcela.valor_da_multa
            total_outros += parcela.outros_acrescimos
            total_desconto += parcela.valor_do_desconto
          end
        end
        # Row
        xml.Row do
          xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };
          xml.Cell { xml.Data 'Totais...>>', 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_retencoes), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_desconto), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_liquido), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_juros), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_multa), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_outros), 'ss:Type' => 'Number' }
          xml.Cell { };
        end

        total_geral_liquido += total_liquido
        total_geral_juros += total_juros
        total_geral_multa += total_multa
        total_geral_outros += total_outros
        total_geral_desconto += total_desconto
        total_geral_retencoes += total_retencoes
        total_final += total_geral
        cont += 1
      end

      xml.Row do
        xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };
        xml.Cell { xml.Data 'Totais Gerais...>>', 'ss:Type' => 'String' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_final), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_retencoes), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_desconto), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_liquido), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_juros), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_multa), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_outros), 'ss:Type' => 'Number' }
        xml.Cell { };
      end

    end
  end
end
