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

      xml.Row do
        xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      @compromissos.each do |nome,compromissos|
        # Header
        xml.Row do
          xml.Cell { xml.Data 'Cliente:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data nome, 'ss:Type' => 'String' }
        end
        compromissos = compromissos.group_by{|compromisso| compromisso.conta.numero_de_controle }
        compromissos.each do |contrato,compromissos|
          xml.Row do
            xml.Cell { xml.Data 'Contrato:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data contrato, 'ss:Type' => 'String' }
          end
          xml.Row do
            xml.Cell { xml.Data 'Dias Atrasados', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Descrição', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Telefone', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Responsável', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Valor em Atraso', 'ss:Type' => 'String' }
          end
          @parcelas = []
          dias_atrasados_por_contrato = 0
          valor_atrasado = 0
          compromissos.each do |compromisso|
            compromisso.conta.parcelas.each{|parcela| @parcelas << parcela if (parcela.data_da_baixa.blank?) && (Date.today > parcela.data_vencimento.to_date) }
            @parcelas.each{|parcela| dias_atrasados_por_contrato = (Date.today - parcela.data_vencimento.to_date).to_i if (Date.today - parcela.data_vencimento.to_date).to_i > dias_atrasados_por_contrato}
            @parcelas.each{|parcela| valor_atrasado += parcela.valor + parcela.valor_dos_juros + parcela.valor_da_multa }
            xml.Row do
              xml.Cell { xml.Data dias_atrasados_por_contrato, 'ss:Type' => 'Number' }
              xml.Cell { xml.Data compromisso.descricao, 'ss:Type' => 'String' }
              xml.Cell { xml.Data compromisso.conta.pessoa.telefone.first, 'ss:Type' => 'String' }
              xml.Cell { xml.Data compromisso.conta.cobrador.nome, 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_atrasado), 'ss:Type' => 'Number' }
            end
          end
        end
      end
    end
  end
end
  
