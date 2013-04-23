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

      # Header
      xml.Row do
        xml.Cell { xml.Data 'Unidade', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Contrato', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Emitido Em', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Carta', 'ss:Type' => 'String' }
      end
      @historico_operacoes.group_by {|historico| historico.retorna_agrupamento_para_pesquisa(params[:busca][:agrupar])}.each do |k, v|
        # Row
        xml.Row do
          xml.Cell { xml.Data "#{params[:busca][:agrupar]}:", 'ss:Type' => 'String' }
          xml.Cell { xml.Data k.nome, 'ss:Type' => 'String' }
        end
        v.each do |historico|
          # Row
          xml.Row do
            xml.Cell { xml.Data historico.conta.unidade.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data historico.conta.numero_de_controle, 'ss:Type' => 'String' }
            xml.Cell { xml.Data historico.conta.pessoa.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data historico.created_at.strftime("%d/%m/%Y %H:%M"), 'ss:Type' => 'String' }
            xml.Cell { xml.Data historico.numero_carta_cobranca, 'ss:Type' => 'String' }
          end

        end
        xml.Row {}
      end

    end

  end
  
end