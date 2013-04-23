xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Contas a Receber Geral - Vendas Realizadas' do
    xml.Table do

      xml.Row do
        xml.Cell{};xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      total_geral = 0

      # Header
      xml.Row do
        xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Contrato', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data Venda', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Vcto', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Inclusão', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'N Parcelas', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Vendedor', 'ss:Type' => 'String' }
      end

      # Rows
      @parcelas.each do |grupo, parcelas|

        xml.Row do
          xml.Cell { xml.Data 'Entidade:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcelas.first.conta.unidade.entidade.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Unidade:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcelas.first.conta.unidade.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Serviço:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data grupo, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Modalidade', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcelas.first.conta.servico.modalidade, 'ss:Type' => 'String' }
        end

        # Row

        contas = []

        total_grupo = 0

        parcelas.each do |parcela|
          contas << parcela.conta
        end

        # Row
        contas.uniq.each do |conta|

          xml.Row do
            xml.Cell { xml.Data conta.pessoa.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.numero_de_controle, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.data_venda, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.dia_do_vencimento, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.data_venda, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.numero_de_parcelas, 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(conta.valor_do_documento), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data conta.nome_vendedor, 'ss:Type' => 'String' }
          end

          total_grupo += conta.valor_do_documento if conta.valor_do_documento
        end

        xml.Row do
          xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };
          xml.Cell { xml.Data 'Total Atividades ...>>', 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_grupo), 'ss:Type' => 'Number' }
        end

        total_geral += total_grupo
      end

      xml.Row do
        xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };xml.Cell { };
        xml.Cell { xml.Data 'Totais ...>>', 'ss:Type' => 'String' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral), 'ss:Type' => 'Number' }
      end

    end

  end
  
end