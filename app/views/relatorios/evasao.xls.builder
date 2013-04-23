xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Contratos Evadidos' do
    xml.Table do

      xml.Row do
        xml.Cell{}
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      xml.Row do
        xml.Cell {xml.Data 'Valor Contrato', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Qtde. Parc', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Valor Parcela', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Vcto. Parc.', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Dias atraso', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Vigêngia - Início', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Vigêngia - Término', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Situação', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Data Evasão', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Data Registro Evasão', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Justificativa', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Conta Contábil', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Unidade Organizacional', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Centro', 'ss:Type'=>'String'}
      end

      @parcelas.each do |grupo_cliente, parcelas|
        total_parcelas = 0
        xml.Row do
          xml.Cell {xml.Data 'Nome: '+ grupo_cliente, 'ss:Type'=> 'String'}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}

          xml.Cell {xml.Data 'Serviço: '+ parcelas.first.conta.servico.descricao, 'ss:Type'=> 'String'}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
        end
        parcelas.each do |parcela|
          xml.Row do
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.conta.valor_do_documento), 'ss:Type' => 'Number'}
            xml.Cell {xml.Data "#{parcela.parcela_mae_id.blank? ? parcela.numero : parcela.numero_parcela_filha} / #{parcela.conta.numero_de_parcelas}", 'ss:Type' => 'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type' => 'Number'}
            xml.Cell {xml.Data parcela.data_vencimento, 'ss:Type' => 'String'}
            xml.Cell {xml.Data parcela.data_vencimento.to_date >= Date.today ? '0' : parcela.dias_em_atraso, 'ss:Type' => 'String'}
            xml.Cell {xml.Data parcela.conta.data_inicio, 'ss:Type' => 'String'}
            xml.Cell {xml.Data parcela.conta.data_final, 'ss:Type' => 'String'}
            xml.Cell {xml.Data parcela.situacao_verbose, 'ss:Type' => 'String'}
            xml.Cell {xml.Data parcela.conta.data_evasao, 'ss:Type' => 'String'}
            xml.Cell {xml.Data parcela.conta.data_registro_evasao, 'ss:Type' => 'String'}
            xml.Cell {xml.Data parcela.conta.justificativa_evasao, 'ss:Type' => 'String'}
            xml.Cell {xml.Data "#{parcela.conta.conta_contabil_receita.codigo_contabil} - #{parcela.conta.conta_contabil_receita.nome}", 'ss:Type' => 'String'}
            xml.Cell {xml.Data "#{parcela.conta.unidade_organizacional.codigo_da_unidade_organizacional} - #{parcela.conta.unidade_organizacional.nome}", 'ss:Type' => 'String'}
            xml.Cell {xml.Data "#{parcela.conta.centro.codigo_centro} - #{parcela.conta.centro.nome}", 'ss:Type' => 'String'}
          end
          total_parcelas += parcela.valor
        end
        xml.Row do
          xml.Cell {xml.Data "Totalizações", 'ss:Type'=>'String'}
          xml.Cell {}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_parcelas), 'ss:Type' => 'Number' }
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
        end

      end
    end
  end
end
