xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Cartas Emitidas' do
    xml.Table do

      # Header
      xml.Row do
        xml.Cell {xml.Data 'Número de Controle', 'ss:Type' => 'String'}
        xml.Cell {xml.Data 'Cliente', 'ss:Type' => 'String'}
        xml.Cell {xml.Data 'Serviço', 'ss:Type' => 'String'}
        xml.Cell {xml.Data 'Data de Recebimento Cliente', 'ss:Type' => 'String'}
        xml.Cell {xml.Data 'Data de Depósito', 'ss:Type' => 'String'}
        xml.Cell {xml.Data 'Valor', 'ss:Type' => 'String'}
      end
      valor_total = 0
      @cartoes.group_by(&:bandeira_verbose).each_pair do |k, v|
        # Row
        xml.Row do
          xml.Cell {xml.Data 'Operadora:', 'ss:Type' => 'String'}
          xml.Cell {xml.Data k, 'ss:Type' => 'String'}
        end
        valor_total_cartao = 0
        v.each do |cartao|
          # Row
          xml.Row do
            xml.Cell {xml.Data cartao.parcela.conta.numero_de_controle, 'ss:Type' => 'String'}
            xml.Cell {xml.Data cartao.parcela.conta.pessoa.nome, 'ss:Type' => 'String'}
            xml.Cell {xml.Data cartao.parcela.servico, 'ss:Type' => 'String'}
            xml.Cell {xml.Data cartao.parcela.data_da_baixa, 'ss:Type' => 'String'}
            xml.Cell {xml.Data cartao.data_do_deposito, 'ss:Type' => 'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(cartao.parcela.valor_liquido), 'ss:Type' => 'Number'}
          end
          valor_total_cartao +=  cartao.parcela.valor_liquido
        end
        xml.Row do
          xml.Cell {}; xml.Cell {}
          xml.Cell {}; xml.Cell {}
          xml.Cell {xml.Data 'Total..>>', 'ss:Type' => 'String'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(valor_total_cartao), 'ss:Type' => 'Number'}
        end
        valor_total += valor_total_cartao
        xml.Row {}
      end
      xml.Row do
        xml.Cell {}; xml.Cell {}
        xml.Cell {}; xml.Cell {}
        xml.Cell {xml.Data 'Total..>>', 'ss:Type' => 'String'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(valor_total), 'ss:Type' => 'Number'}
      end

    end

  end
  
end