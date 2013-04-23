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
      total_saldo_final = 0
      total_geral_executado = 0
      total_contratos_mes = 0
      total_executado_porcentagem = 0
      total_saldo_anterior = 0

      xml.Row do
        xml.Cell {xml.Data "Número de Controle", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Cliente", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Serviços", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Vigencia - Início", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Vigencia - Término", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Início Serviço", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Término Serviço", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Valor - Contrato", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Saldo Anterior", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Valor Ctrs/Mês", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Executado (%)", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Valor Executado", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Saldo Final", 'ss:Type'=>'String'}
      end


      total_geral_contratos = 0
      total_saldo_final = 0
      total_geral_executado = 0
      total_contratos_mes = 0 
      total_executado_porcentagem = 0
      total_saldo_anterior = 0
      saldo_mes_final = 0 

               
      @recebimentos.each do |grupo_servico, contas|
        valor_movimento = 0

        contas.each do |conta|
          contrato = RecebimentoDeConta.find(conta)
          
          array_valor_movimento_do_mes = contrato.movimentos.collect{|movimento| movimento.data_lancamento.to_date.month == params['busca']['mes'].to_i && movimento.tipo_lancamento == 'C' ? movimento.valor_total : 0} 
          valor_movimento_do_mes = array_valor_movimento_do_mes.max == 0 ? 0 : array_valor_movimento_do_mes.max 
          array_contabilizacoes = contrato.movimentos.collect{|movimento| movimento.data_lancamento.to_date.month <= params['busca']['mes'].to_i && movimento.data_lancamento.to_date.year == Date.today.year && movimento.tipo_lancamento == 'C' ? movimento.valor_total : 0} 
          porcentagem = valor_movimento_do_mes == 0 ? 0 : conta.porcentagem_contabilizacao_receitas(session[:ano], params['busca']['mes'].to_i) 
          saldo = conta.valor_do_documento - array_contabilizacoes.sum 
          if saldo < 0 
            saldo = conta.valor_original - array_contabilizacoes.sum 
          end 
          # saldo_anterior = saldo + valor_movimento_do_mes 
          if (params['busca']['mes'].to_i == conta.data_inicio.to_date.month.to_i) && (conta.data_inicio.to_date.year == Date.today.year)
             saldo_anterior = 0 
          else 
            saldo_anterior = saldo + valor_movimento_do_mes 
          end

          nome = conta.pessoa.fisica? ? conta.pessoa.nome : conta.pessoa.razao_social

          xml.Row do
            xml.Cell {xml.Data conta.numero_de_controle, 'ss:Type'=>'String'}
            xml.Cell {xml.Data nome, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.servico.descricao, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_inicio, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_final, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_inicio_servico, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_final_servico, 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(conta.valor_do_documento), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_anterior), 'ss:Type'=>'Number'}            
            a= conta.data_inicio.to_date.month == params['busca']['mes'].to_i && conta.data_inicio.to_date.year == Date.today.year ? preco_formatado_com_decimal_ponto(conta.valor_do_documento) : 0
            xml.Cell {xml.Data a, 'ss:Type'=>'Number'}
           
            saldo_mes_final += conta.data_inicio.to_date.month == params['busca']['mes'].to_i && conta.data_inicio.to_date.year == Date.today.year ? conta.valor_do_documento : 0

            b= porcentagem == 0 ? 0 : porcentagem
            xml.Cell {xml.Data b, 'ss:Type'=>'Number'}
            c= valor_movimento_do_mes == 0 ? 0 : preco_formatado_com_decimal_ponto(valor_movimento_do_mes)
            xml.Cell {xml.Data c, 'ss:Type'=>'Number'}
            d= saldo == 0 ? 0 : preco_formatado_com_decimal_ponto(saldo)
            xml.Cell {xml.Data  d, 'ss:Type'=>'Number'}
          end


           if conta.data_inicio.to_date.month == params['busca']['mes'].to_i
            total_contratos_mes += conta.valor_do_documento
           end
        total_saldo_anterior += saldo_anterior
        total_geral_executado += valor_movimento_do_mes
        total_geral_contratos += conta.valor_do_documento
        total_saldo_final += saldo 































        end
      end
  total_executado_porcentagem = (total_geral_executado * 100.0) / total_geral_contratos
 xml.Row do
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {xml.Data 'Totalização', 'ss:Type'=>'String'}
        xml.Cell {}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_geral_contratos), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_saldo_anterior), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_mes_final), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data format("%.2f", total_executado_porcentagem), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_geral_executado), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_saldo_final), 'ss:Type'=>'Number'}
      end



  end
end
end