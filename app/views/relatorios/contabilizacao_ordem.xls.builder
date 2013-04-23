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

      xml.Row do
        xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      @movimentos.each do |movimento|

        # Row
        xml.Row do
          xml.Cell {xml.Data "Número da Parcela: #{movimento.numero_da_parcela}", 'ss:Type' => 'String'}
        end
        xml.Row do
          xml.Cell {xml.Data "Data do Lançamento: #{movimento.data_lancamento}", 'ss:Type' => 'String'}
        end
        xml.Row do
          xml.Cell {xml.Data "Número de Controle: #{movimento.numero_de_controle}", 'ss:Type' => 'String'}
        end
        xml.Row do
          xml.Cell {xml.Data "Fornecedor/Cliente: #{movimento.pessoa.nome}", 'ss:Type' => 'String'}
        end
        xml.Row do
          xml.Cell {xml.Data "Histórico: #{movimento.historico}", 'ss:Type' => 'String'}
        end

        xml.Row do
          xml.Cell {xml.Data 'D/C', 'ss:Type' => 'String'}
          xml.Cell {xml.Data 'Conta Contábil', 'ss:Type' => 'String'}
          xml.Cell {xml.Data 'Unidade Organizacional', 'ss:Type' => 'String'}
          xml.Cell {xml.Data 'Centro de Responsabilidade', 'ss:Type' => 'String'}
          xml.Cell {xml.Data 'Valor (R\$)', 'ss:Type' => 'String'}
        end
        movimento.itens_movimentos.each do |item|
          xml.Row do
            xml.Cell {xml.Data item.tipo_verbose, 'ss:Type' => 'String'}
            xml.Cell {xml.Data "#{item.plano_de_conta.codigo_contabil} - #{item.plano_de_conta.nome}", 'ss:Type' => 'String'}
            xml.Cell {xml.Data "#{item.unidade_organizacional.codigo_da_unidade_organizacional} - #{item.unidade_organizacional.nome}", 'ss:Type' => 'String'}
            xml.Cell {xml.Data "#{item.centro.codigo_centro} - #{item.centro.nome}", 'ss:Type' => 'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(item.valor) , 'ss:Type' => 'Number'}
          end
        end
        xml.Row do
          xml.Cell {};xml.Cell{};xml.Cell{}
          xml.Cell {xml.Data "Valor Total: ", 'ss:Type' => 'String'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(movimento.valor_total), 'ss:Type' => 'Number'}
        end
      end

    end

  end
  
end