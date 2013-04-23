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
        xml.Cell{}
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end
      
      xml.Row do
        xml.Cell {xml.Data "Data de Referência: #{params[:busca][:data_max]}", 'ss:Type'=>'String'}
      end
      xml.Row do
        xml.Cell {xml.Data 'Conta', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Saldo Anterior', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Entradas', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Saidas', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Saldo Atual', 'ss:Type'=>'String'}
      end
      saldo_anterior_total = 0; total_entradas = 0; total_saidas = 0; saldo_atual_total = 0
      (@itens_movimentos.group_by { |i| i.plano_de_conta.contas_corrente }).each_pair do |conta_corrente, items|
        saldo_anterior = 0; entradas = 0; saidas = 0; entradas_do_dia = 0; saidas_do_dia = 0; saldo_atual = 0
        items.each do |item|
          if (item.movimento.data_lancamento.to_date == params[:busca][:data_max].to_date)
            item.tipo == "D" ? entradas_do_dia += item.valor : saidas_do_dia += item.valor
          else
            item.tipo == "D" ? entradas += item.valor : saidas += item.valor
          end
        end
        saldo_anterior = (entradas - saidas); saldo_atual = saldo_anterior + (entradas_do_dia - saidas_do_dia)
        saldo_anterior_total += saldo_anterior; total_entradas += entradas_do_dia; total_saidas += saidas_do_dia; saldo_atual_total += saldo_atual
        xml.Row do
          xml.Cell {xml.Data conta_corrente.resumo, 'ss:Type'=>'String'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_anterior), 'ss:Type'=>'Number'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(entradas_do_dia), 'ss:Type'=>'Number'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saidas_do_dia), 'ss:Type'=>'Number'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_atual), 'ss:Type'=>'Number'}
        end
      end
      xml.Row do
        xml.Cell {xml.Data 'Total', 'ss:Type'=>'String'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_anterior_total), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_entradas), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_saidas), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_atual_total), 'ss:Type'=>'Number'}
      end
    end
  end
end