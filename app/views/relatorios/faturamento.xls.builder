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

        contas.each do |contrato|
          contrato = RecebimentoDeConta.find(contrato.id)

          array_valor_movimento_do_mes = contrato.movimentos.collect{|movimento| movimento.data_lancamento.to_date.month == params['busca']['mes'].to_i && movimento.tipo_lancamento == 'C' ? movimento.valor_total : 0}
          valor_movimento_do_mes = array_valor_movimento_do_mes.max == 0 ? 0 : array_valor_movimento_do_mes.max
          #array_contabilizacoes = contrato.movimentos.collect{|movimento| movimento.data_lancamento.to_date.month <= params['busca']['mes'].to_i && movimento.data_lancamento.to_date.year == Date.today.year && movimento.tipo_lancamento == 'C' ? movimento.valor_total : 0}

        # CORREÇÃO
          array_contabilizacoes = contrato.movimentos.collect{|movimento| movimento.valor_total if movimento.data_lancamento.to_date.month <= params['busca']['mes'].to_i && movimento.data_lancamento.to_date.year == Date.today.year && movimento.tipo_lancamento == 'C'}.compact.sum
          array_contabilizacoes_anos_anteriores = contrato.movimentos.collect{|movimento| movimento.valor_total if movimento.data_lancamento.to_date.year < Date.today.year && movimento.tipo_lancamento == 'C'}.compact.sum
        # CORREÇÃO

          porcentagem = valor_movimento_do_mes == 0 ? 0 : contrato.porcentagem_contabilizacao_receitas(session[:ano], params['busca']['mes'].to_i)
          saldo = contrato.valor_do_documento - (array_contabilizacoes + array_contabilizacoes_anos_anteriores)
          if saldo < 0
            saldo = contrato.valor_original - (array_contabilizacoes + array_contabilizacoes_anos_anteriores)
          end

          # saldo_anterior = saldo + valor_movimento_do_mes
          if (params['busca']['mes'].to_i == contrato.data_inicio.to_date.month.to_i) && (contrato.data_inicio.to_date.year == Date.today.year)
             saldo_anterior = 0
          else
            saldo_anterior = saldo + valor_movimento_do_mes
            if valor_movimento_do_mes > saldo_anterior
              valor_movimento_do_mes = saldo_anterior
            end
          end

          if saldo < 0
            saldo = 0
          end

          nome = contrato.pessoa.fisica? ? contrato.pessoa.nome : contrato.pessoa.razao_social

          xml.Row do
            xml.Cell {xml.Data contrato.numero_de_controle, 'ss:Type'=>'String'}
            xml.Cell {xml.Data nome, 'ss:Type'=>'String'}
            xml.Cell {xml.Data contrato.servico.descricao, 'ss:Type'=>'String'}
            xml.Cell {xml.Data contrato.data_inicio, 'ss:Type'=>'String'}
            xml.Cell {xml.Data contrato.data_final, 'ss:Type'=>'String'}
            xml.Cell {xml.Data contrato.data_inicio_servico, 'ss:Type'=>'String'}
            xml.Cell {xml.Data contrato.data_final_servico, 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(contrato.valor_do_documento), 'ss:Type'=>'Number'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_anterior), 'ss:Type'=>'Number'}
            a = contrato.data_inicio.to_date.month == params['busca']['mes'].to_i && contrato.data_inicio.to_date.year == Date.today.year ? preco_formatado_com_decimal_ponto(contrato.valor_do_documento) : 0
            xml.Cell {xml.Data a, 'ss:Type'=>'Number'}

            saldo_mes_final += contrato.data_inicio.to_date.month == params['busca']['mes'].to_i && contrato.data_inicio.to_date.year == Date.today.year ? contrato.valor_do_documento : 0

            b = porcentagem == 0 ? 0 : porcentagem
            xml.Cell {xml.Data b, 'ss:Type'=>'Number'}
            c = valor_movimento_do_mes == 0 ? 0 : preco_formatado_com_decimal_ponto(valor_movimento_do_mes)
            xml.Cell {xml.Data c, 'ss:Type'=>'Number'}
            d = saldo == 0 ? 0 : preco_formatado_com_decimal_ponto(saldo)
            xml.Cell {xml.Data  d, 'ss:Type'=>'Number'}
          end

          if contrato.data_inicio.to_date.month == params['busca']['mes'].to_i
            total_contratos_mes += contrato.valor_do_documento
          end
          total_saldo_anterior += saldo_anterior
          total_geral_executado += valor_movimento_do_mes
          total_geral_contratos += contrato.valor_do_documento
          total_saldo_final += saldo
        end
      end

      para_percent = total_geral_contratos - total_saldo_final
      total_executado_porcentagem = (para_percent * 100.0) / total_geral_contratos

      xml.Row do
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {xml.Data 'Totalização', 'ss:Type'=>'String'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_geral_contratos), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_saldo_anterior), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(saldo_mes_final), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data format('%.2f', total_executado_porcentagem), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_geral_executado), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_saldo_final), 'ss:Type'=>'Number'}
      end
    end
  end
end
