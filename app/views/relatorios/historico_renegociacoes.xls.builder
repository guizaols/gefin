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
        xml.Cell{};xml.Cell{};xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      @recebimentos_renegociados.each do |recebimento_renegociado|
        xml.Row do
          xml.Cell {xml.Data "Contrato: #{recebimento_renegociado.numero_de_controle}", 'ss:Type'=>'String'}
          xml.Cell{}
          xml.Cell{}
          xml.Cell {xml.Data "Unidade: #{recebimento_renegociado.unidade.nome}", 'ss:Type'=>'String'}
        end

        xml.Row do
          xml.Cell {xml.Data "Serviço: #{recebimento_renegociado.servico.descricao}", 'ss:Type'=>'String'}
          xml.Cell{}
          xml.Cell{}
          xml.Cell {xml.Data "Cliente: #{recebimento_renegociado.pessoa.nome rescue 'Pessoa Excluída'}", 'ss:Type'=>'String'}
        end

        xml.Row do
          xml.Cell {xml.Data "Aluno: #{recebimento_renegociado.dependentes.collect(&:nome).join(', ') rescue 'Nenhum aluno vinculado a esta conta.'}", 'ss:Type'=>'String'}
          xml.Cell{}
          xml.Cell{}
          #          xml.Cell {xml.Data "Situação: #{recebimento_renegociado.situacao_verbose}", 'ss:Type'=>'String'}
        end

        #        xml.Row do
        #          xml.Cell {xml.Data "Número de Renegociações: #{recebimento_renegociado.numero_de_renegociacoes}", 'ss:Type'=>'String'}
        #          xml.Cell{}
        #          xml.Cell{}
        #          xml.Cell {xml.Data "Valor do Documento: #{preco_formatado_com_decimal_ponto(recebimento_renegociado.valor_do_documento, 'R$') }", 'ss:Type'=>'String'}
        #        end

        if recebimento_renegociado.parcelas.blank?
          xml.Row do
            xml.Cell {xml.Data 'Não foram geradas parcelas para esta conta.', 'ss:Type'=>'String'}
          end
        else
          xml.Row do
            xml.Cell {xml.Data 'Número', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Vencimento', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Valor', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Juros', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Multa', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Honorário', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Protesto', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Outros', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Desconto', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Boleto', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Pago Em', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Valor Pago', 'ss:Type'=>'String'}
            xml.Cell {xml.Data 'Situação', 'ss:Type'=>'String'}
          end
          hash_com_valores = {:valor => 0, :valor_liquido => 0, :valor_multa => 0,
            :valor_juros => 0, :outros_acrescimos => 0, :valor_desconto => 0, :honorarios => 0, :protesto => 0,
            :taxa_boleto => 0}
          recebimento_renegociado.parcelas.each do |parcela|
            xml.Row do
              xml.Cell {xml.Data parcela.numero, 'ss:Type'=>'Number'}
              xml.Cell {xml.Data data_formatada(parcela.data_vencimento), 'ss:Type'=>'String'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.valor_dos_juros), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.valor_da_multa), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.honorarios), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.protesto), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.outros_acrescimos), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.valor_do_desconto), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.taxa_boleto), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data parcela.data_da_baixa, 'ss:Type'=>'String'}
              xml.Cell {xml.Data preco_formatado_com_decimal_ponto(parcela.valor_liquido), 'ss:Type'=>'Number'}
              xml.Cell {xml.Data parcela.situacao_verbose, 'ss:Type'=>'String'}
            end
            [[:valor, parcela.valor], [:valor_liquido, parcela.valor_liquido],
              [:outros_acrescimos, parcela.outros_acrescimos],[:valor_multa, parcela.valor_da_multa],
              [:valor_juros, parcela.valor_dos_juros], [:valor_desconto, parcela.valor_do_desconto],
              [:honorarios, parcela.honorarios], [:protesto, parcela.protesto],
              [:taxa_boleto, parcela.taxa_boleto]].each {|item| hash_com_valores[item.first] += item.last}
          end
          xml.Row do
            xml.Cell{}
            xml.Cell {xml.Data 'Totais', 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:valor]), 'ss:Type'=>'Number'}
#            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:valor_liquido], 'R$'), 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:valor_juros]), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:valor_multa]), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:honorarios]), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:protesto]), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:outros_acrescimos]), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:valor_desconto]), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:taxa_boleto]), 'ss:Type'=>'Number'}
            xml.Cell{}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(hash_com_valores[:valor_liquido]), 'ss:Type'=>'Number'}
          end
        end
      end
    end
  end
end