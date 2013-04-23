xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Contas a Pagar - Visão Contábil' do
    xml.Table do
      xml.Row do
        xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
        xml.Cell{};xml.Cell{};xml.Cell{};xml.Cell{};
      end
      
      total_geral_valor = 0

      xml.Row do
        xml.Cell { xml.Data 'Documento', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Número de Controle', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Fornecedor', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data Emissão', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data Vencimento', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor Líquido', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data da Baixa', 'ss:Type' => 'String' }
      end

      @parcelas.each do |parcela|
        valor_liquido_percela = parcela.valor + parcela.valor_dos_juros + parcela.valor_da_multa + parcela.valores_novos_recebimentos + parcela.outros_acrescimos - parcela.soma_impostos_da_parcela - parcela.valor_do_desconto
        # Row
        xml.Row do
          xml.Cell { xml.Data parcela.conta.numero_nota_fiscal_string, 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcela.conta.numero_de_controle, 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcela.conta.pessoa.fisica? ? parcela.conta.pessoa.nome : parcela.conta.pessoa.razao_social, 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcela.conta.data_emissao, 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_liquido_percela), 'ss:Type' => 'Number' }
          if !parcela.data_da_baixa.blank? && Date.today > parcela.data_da_baixa.to_date
            xml.Cell { xml.Data parcela.data_da_baixa, 'ss:Type' => 'String' }
          else
            xml.Cell {xml.Data '', 'ss:Type' => 'String' }
          end
        end
        total_geral_valor += valor_liquido_percela
      end
      xml.Row do
        xml.Cell { }; xml.Cell { }; xml.Cell { };
        xml.Cell { xml.Data 'Totais ...>>', 'ss:Type' => 'String' }
        xml.Cell { };
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral_valor), 'ss:Type' => 'Number' }
      end

    end
  end
end
