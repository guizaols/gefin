xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Receitas por Procedimento' do
    xml.Table do

      xml.Row do
        xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      @lancamentos.each do |unidade,lancamentos|
        # Header
        xml.Row do
          xml.Cell { xml.Data 'Unidade Organizacional:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data unidade, 'ss:Type' => 'String' }
          xml.Cell {};xml.Cell {};xml.Cell {}
        end

        lancamentos = lancamentos.group_by{|lancamento| lancamento.centro.nome}

        lancamentos.each do |centro,lancamentos|

          xml.Row do
            xml.Cell { xml.Data 'Centros de Responsabilidade:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data centro, 'ss:Type' => 'String' }
            xml.Cell {};xml.Cell {};xml.Cell {}
          end

          xml.Row do
            xml.Cell { xml.Data 'Data', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Histórico', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Lançamento', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Número Documento', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Crédito', 'ss:Type' => 'String' }
          end

          total_geral = 0
          total_conta = 0

          lancamentos = lancamentos.group_by{|lancamento| "#{lancamento.plano_de_conta.codigo_contabil} - #{lancamento.plano_de_conta.nome}" }
          lancamentos.each do |nome,lancamentos|
            total_conta = 0
            xml.Row do
              xml.Cell { xml.Data nome, 'ss:Type' => 'String' }
            end
            lancamentos.each do |lancamento|
              xml.Row do
                xml.Cell { xml.Data lancamento.movimento.data_lancamento, 'ss:Type' => 'String' }
                xml.Cell { xml.Data lancamento.movimento.historico, 'ss:Type' => 'String' }
                xml.Cell { xml.Data lancamento.tipo, 'ss:Type' => 'String' }
                xml.Cell { xml.Data lancamento.movimento.numero_de_controle, 'ss:Type' => 'String' }
                xml.Cell { xml.Data preco_formatado_com_decimal_ponto(lancamento.valor), 'ss:Type' => 'Number' }
              end
              total_conta += lancamento.valor
            end
            total_geral += total_conta
            xml.Row do
              xml.Cell {};xml.Cell {};xml.Cell {}
              xml.Cell { xml.Data 'Total Conta:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_conta) , 'ss:Type' => 'Number' }
            end
          end
          xml.Row do
            xml.Cell {};xml.Cell {};xml.Cell {}
            xml.Cell { xml.Data 'Total Geral:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral) , 'ss:Type' => 'Number' }
          end

        end
        xml.Row do
          xml.Cell {}
        end
      end

    end
   
  end

end
