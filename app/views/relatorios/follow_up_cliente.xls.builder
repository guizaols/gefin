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
        xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      # Header
      xml.Row do
        xml.Cell { xml.Data 'Data', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Descrição', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Carta', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Responsável', 'ss:Type' => 'String' }
      end

      @historico_operacoes.each do |followup|

        # Row
        xml.Row do
          xml.Cell { xml.Data followup.created_at.to_s_br, 'ss:Type' => 'String' }
          xml.Cell { xml.Data followup.descricao, 'ss:Type' => 'String' }
          xml.Cell { xml.Data !followup.numero_carta_cobranca.blank? ? followup.numero_carta_cobranca : '', 'ss:Type' => 'String' }
          xml.Cell { xml.Data followup.conta.pessoa.nome, 'ss:Type' => 'String' }
        end

      end

    end
   
  end

end
  
