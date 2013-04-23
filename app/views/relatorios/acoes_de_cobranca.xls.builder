xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Geral do Contas a Receber - Ações de Cobrança' do
    xml.Table do

      xml.Row do
        xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      xml.Row do
        xml.Cell { xml.Data 'Data', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Histórico', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Carta', 'ss:Type' => 'String' }
      end

      @historicos.each do |cobrador, historicos_cobrador|
        xml.Row do
          xml.Cell { xml.Data 'Funcionário', 'ss:Type' => 'String' }
          xml.Cell { xml.Data cobrador, 'ss:Type' => 'String' }
        end

        historicos_cobrador.group_by{|historico| historico.conta.servico.descricao}.each do |servico, historico_servico|

          xml.Row do
            xml.Cell { xml.Data 'Entidade', 'ss:Type' => 'String' }
            xml.Cell { xml.Data historico_servico.first.conta.unidade.entidade.nome, 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Serviço', 'ss:Type' => 'String' }
            xml.Cell { xml.Data servico, 'ss:Type' => 'String' }
          end

          historico_servico.group_by{|historico| historico.conta.numero_de_controle}.each do |conta, historico_servico|

            xml.Row do
              xml.Cell { xml.Data 'Contrato', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta, 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
              xml.Cell { xml.Data historico_servico.first.conta.pessoa.nome, 'ss:Type' => 'String' }
            end

            historico_servico.each do |historico|

              unless historico.blank?

                xml.Row do
                  xml.Cell { xml.Data historico.created_at.to_date.to_s_br, 'ss:Type' => 'String' }
                  xml.Cell { xml.Data "#{historico.descricao}. #{historico.justificativa unless historico.justificativa.blank?}", 'ss:Type' => 'String' }
                  xml.Cell { xml.Data historico.numero_carta_cobranca, 'ss:Type' => 'String' }  if historico.numero_carta_cobranca
                end

              end

            end

          end

        end

      end

    end

  end
  
end