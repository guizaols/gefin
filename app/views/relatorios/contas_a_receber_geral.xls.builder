xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Contas a Receber - Geral' do
    xml.Table do

      xml.Row do
        xml.Cell{};xml.Cell{};xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      total_multa = 0
      total_juros = 0
      total_desconto = 0
      total_honorarios = 0
      total_protesto = 0
      total_taxa_boleto = 0
      total_outros = 0
      total_geral_a_receber = 0
      total_geral = 0

      # Header
      xml.Row do
        xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Contrato', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Juros', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Multa', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Honorário', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Protesto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Outros', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Desconto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Boleto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Vcto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data Rec', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Vendedor', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Recebido', 'ss:Type' => 'String' }
      end

      # Rows
      @parcelas.each do |grupo, parcelas|

        xml.Row do
          xml.Cell { xml.Data 'Entidade:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcelas.first.unidade.entidade.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Unidade:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcelas.first.unidade.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Serviço:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data grupo, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Modalidade', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcelas.first.conta.servico.modalidade, 'ss:Type' => 'String' }
        end

        # Row
        total_grupo = 0
        parcelas.each do |parcela|
          xml.Row do
            xml.Cell { xml.Data parcela.conta.pessoa.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.conta.numero_de_controle, 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_dos_juros), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_da_multa), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.honorarios), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.protesto), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.outros_acrescimos), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_do_desconto), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.taxa_boleto), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.data_da_baixa, 'ss:Type' => 'String' }
            xml.Cell { xml.Data parcela.conta.nome_vendedor, 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_liquido), 'ss:Type' => 'Number' }
          end
          total_juros += parcela.valor_dos_juros
          total_multa += parcela.valor_da_multa
          total_honorarios += parcela.honorarios
          total_protesto += parcela.protesto
          total_outros += parcela.outros_acrescimos
          total_desconto += parcela.valor_do_desconto
          total_taxa_boleto += parcela.taxa_boleto
          total_grupo += parcela.valor_liquido
        end

        total_geral += total_grupo

        xml.Row do
          xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };
          xml.Cell { xml.Data 'Total Atividade ...>>', 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_grupo), 'ss:Type' => 'Number' }
        end
      end

      xml.Row do
        xml.Cell { xml.Data 'Totais ...>>', 'ss:Type' => 'String' }
        xml.Cell { };
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_juros), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_multa), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_honorarios), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_protesto), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_outros), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_desconto), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_taxa_boleto), 'ss:Type' => 'Number' }
        xml.Cell { };xml.Cell { };xml.Cell { };
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral), 'ss:Type' => 'Number' }
      end
      
    end

  end
  
end