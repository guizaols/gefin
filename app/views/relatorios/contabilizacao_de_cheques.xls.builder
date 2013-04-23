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
        xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type' => 'String'}
      end

      # Row
      xml.Row do
        xml.Cell {xml.Data 'Unidade', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Cliente', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Banco', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Cheque', 'ss:Type'=>'String'}
        xml.Cell {xml.Data params["busca"]["situacao"] == Cheque::DEVOLVIDO ? "Devol" : "Rcbto", 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Vencimento', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Valor', 'ss:Type'=>'String'}
        xml.Cell {xml.Data 'Situação', 'ss:Type'=>'String'}
      end
      
      @cheques.each do |cheque|
        if cheque.situacao == Cheque::BAIXADO || cheque.situacao == Cheque::REAPRESENTADO
          data = cheque.data_do_deposito
        elsif cheque.situacao == Cheque::GERADO
          data = cheque.data_de_recebimento
        elsif cheque.situacao == Cheque::DEVOLVIDO
          data = cheque.data_devolucao
        elsif cheque.situacao == Cheque::ABANDONADO
          data = cheque.data_abandono
        end
        xml.Row do
          xml.Cell {xml.Data cheque.parcela.conta.unidade.nome, 'ss:Type'=>'String'}
          xml.Cell {xml.Data cheque.parcela.conta.nome_pessoa, 'ss:Type'=>'String'}
          xml.Cell {xml.Data cheque.banco.descricao, 'ss:Type'=>'String'}
          xml.Cell {xml.Data cheque.numero, 'ss:Type'=>'String'}
          xml.Cell {xml.Data data, 'ss:Type'=>'String'}
          xml.Cell {xml.Data cheque.parcela.data_vencimento, 'ss:Type'=>'String'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(cheque.parcela.valor), 'ss:Type'=>'Number'}
          xml.Cell {xml.Data cheque.situacao_verbose, 'ss:Type'=>'String'}
        end
      end
    end
  end
end