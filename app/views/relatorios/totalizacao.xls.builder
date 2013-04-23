xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Totalizações' do
    xml.Table do

      # Header
      xml.Row do
        xml.Cell { xml.Data @titulo, 'ss:Type' => 'String'}
      end
      xml.Row do
        xml.Cell { xml.Data gera_periodo_relatorio(params[:busca][:periodo_min], params[:busca][:periodo_max], params[:busca][:periodo]),  'ss:Type' => 'String' }
      end
      if params["busca"]["opcao_relatorio"] == "1" || params["busca"]["opcao_relatorio"] == "3"
        xml.Row do
          xml.Cell { xml.Data 'Unidade', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Serviços/Atividade', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Modalidade', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Total a Receber', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Total Recebido', 'ss:Type' => 'String' }
        end
        # Rows
        @parcelas.group_by{ |parcela| parcela.conta.servico.descricao }.each do |key, value|
          xml.Row do
            xml.Cell { xml.Data value.first.conta.unidade.nome, 'ss:Type' => 'String'}
            xml.Cell { xml.Data value.first.conta.servico.descricao, 'ss:Type' => 'String' }
            xml.Cell { xml.Data value.first.conta.servico.modalidade, 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(value.collect{|parcela| parcela.valor}.sum), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(value.collect{|parcela| parcela.valor_liquido}.sum), 'ss:Type' => 'Number' }
          end
        end
        # Total
        xml.Row do
          xml.Cell {}
          xml.Cell {}
          xml.Cell {xml.Data "Total....>>", 'ss:Type' => 'String'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(@parcelas.sum(&:valor)), 'ss:Type' => 'Number'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(@parcelas.sum(&:valor_liquido)), 'ss:Type' => 'Number'}
        end

      else
        xml.Row do
          xml.Cell { xml.Data 'Unidade', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Serviços/Atividade', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Modalidade', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Total a Receber', 'ss:Type' => 'String' }
        end
        # Rows
        @parcelas.group_by{ |parcela| parcela.conta.servico.descricao }.each do |key, value|
          xml.Row do
            xml.Cell { xml.Data value.first.conta.unidade.nome, 'ss:Type' => 'String'}
            xml.Cell { xml.Data value.first.conta.servico.descricao, 'ss:Type' => 'String' }
            xml.Cell { xml.Data value.first.conta.servico.modalidade, 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(value.collect{|parcela| parcela.valor}.sum), 'ss:Type' => 'Number' }
          end
        end
        # Total
        xml.Row do
          xml.Cell {}
          xml.Cell {}
          xml.Cell {xml.Data "Total....>>", 'ss:Type' => 'String'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(@parcelas.sum(&:valor)), 'ss:Type' => 'Number'}
        end
      end
    end
  end
end