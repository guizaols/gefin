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
        xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      # Row
      total_geral_contratos = 0
      total_geral_parcelas = 0
      total_geral_executado = 0

      xml.Row do
        xml.Cell {xml.Data "Número de Controle", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Cliente", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Serviços", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Vigencia - Início", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Vigencia - Término", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Início Serviço", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Término Serviço", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Valor - Contrato", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Valor - Parcela", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Conta Contábil", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Unidade", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Centro", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Executado (%)", 'ss:Type'=>'String'}
      end

      @recebimentos.each do |grupo_servico, contas|
        total_contrato = 0
        total_parcela = 0
        total_executado = 0

        contas.each do |conta|
          xml.Row do
             xml.Cell {xml.Data conta.numero_de_controle, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.pessoa.nome, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.servico.descricao, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_inicio, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_final, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_inicio_servico, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_final_servico, 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(conta.valor_do_documento), 'ss:Type'=>'Number'}

            array_valor_movimento = conta.movimentos.collect{|movimento| movimento.valor_total if movimento.data_lancamento.to_date.month == params["busca"]["mes"].to_i && !movimento.lancamento_inicial}.compact
            valor_movimento = array_valor_movimento.max == 0 ? 0 : array_valor_movimento.max
            porcentagem = valor_movimento == 0 ? 0 : conta.porcentagem_contabilizacao_receitas(session[:ano], params["busca"]["mes"].to_i)

            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(valor_movimento), 'ss:Type'=>'Number' }
            xml.Cell {xml.Data "#{conta.conta_contabil_receita.codigo_contabil} - #{conta.conta_contabil_receita.nome}", 'ss:Type'=>'String' }
            xml.Cell {xml.Data "#{conta.unidade_organizacional.codigo_da_unidade_organizacional} - #{conta.unidade_organizacional.nome}", 'ss:Type'=>'String' }
            xml.Cell {xml.Data "#{conta.centro.codigo_centro} - #{conta.centro.nome}", 'ss:Type'=>'String' }
            xml.Cell {xml.Data format("%.2f", porcentagem), 'ss:Type'=>'Number' }

            total_contrato

            total_contrato += conta.valor_do_documento
            total_parcela += valor_movimento
          end
        end

        total_executado = (total_parcela * 100.0) / total_contrato

        xml.Row do
          xml.Cell {}
          xml.Cell {}
              xml.Cell {}
          xml.Cell {xml.Data "Totalização", 'ss:Type'=>'String'}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_contrato), 'ss:Type'=>'Number'}
          xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_parcela), 'ss:Type'=>'Number'}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {}
          xml.Cell {xml.Data format("%.2f", total_executado), 'ss:Type'=>'Number'}
        end
        total_geral_contratos += total_contrato
        total_geral_parcelas += total_parcela
      end

      total_geral_executado = (total_geral_parcelas * 100.0) / total_geral_contratos

      xml.Row do
        xml.Cell {}
           xml.Cell {}
        xml.Cell {}
        xml.Cell {xml.Data "Total Geral", 'ss:Type'=>'String'}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_geral_contratos), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_geral_parcelas), 'ss:Type'=>'Number'}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {xml.Data format("%.2f", total_geral_executado), 'ss:Type'=>'Number'}
      end
    end
  end
end
