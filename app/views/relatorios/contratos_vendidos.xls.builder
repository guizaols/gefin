xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do



  xml.Worksheet 'ss:Name' => 'Faturamento' do

    xml.Table do

      xml.Row do
        xml.Cell{};xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end
      xml.Row do        
      end
      xml.Row do
        xml.Cell{};xml.Cell{};xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data "#{Date::MONTHNAMES[params[:busca][:mes].to_i]}/#{session[:ano]}", 'ss:Type'=>'String'}
      end
      xml.Row do
      end

      # Row
      total_geral_contratos = 0
  
      xml.Row do
        xml.Cell {xml.Data "Número de Controle", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Data de Início", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Cliente", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Serviços", 'ss:Type'=>'String'}
       
        xml.Cell {xml.Data "Data Cancelamento" , 'ss:Type'=>'String'}
                xml.Cell {xml.Data "Data Evasão" , 'ss:Type'=>'String'}
       xml.Cell {xml.Data "Situação" , 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Valor Contrato", 'ss:Type'=>'String'}
      end

 @recebimentos.each do |conta|
  nome = conta.pessoa.fisica? ? conta.pessoa.nome : conta.pessoa.razao_social
  total_geral_contratos+= conta.valor_do_documento
         xml.Row do
            xml.Cell {xml.Data conta.numero_de_controle, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_inicio, 'ss:Type'=>'String'}
            xml.Cell {xml.Data nome, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.servico.descricao, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_cancelamento, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_evasao, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.situacao_fiemt_verbose, 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(conta.valor_do_documento), 'ss:Type' => 'Number'}
        end

end

      xml.Row do
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
         xml.Cell {}
        xml.Cell {xml.Data 'Totalização', 'ss:Type'=>'String'}
        xml.Cell {}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_geral_contratos), 'ss:Type'=>'Number'}
      end



  end
end
end