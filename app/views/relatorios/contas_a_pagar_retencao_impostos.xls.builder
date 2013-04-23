xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Contas a Receber - Geral' do
    xml.Table do

      if params[:busca][:pessoa].to_i == Pessoa::FISICA
        total_inss_11 = 0; total_inss_20 = 0; total_irrf_75 = 0; total_irrf_275 = 0; total_bruto = 0; total_liquido = 0
        xml.Row do
          xml.Cell{};xml.Cell{};
          xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
        end

        xml.Row do
          xml.Cell { xml.Data 'Nome', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Doc/Nº', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'Valor Bruto', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'INSS 11%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'INSS 20%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'IRRF 7.5%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'IRRF 27.5%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'Líquido a Pagar', 'ss:Type'=>'String'}
        end
        xml.Row{}
        @lancamentos.each do |conta, lancamentos|
          inss_11 = 0; inss_20 = 0; irrf_75 = 0; irrf_275 = 0; valor_liquido = 0; valor_bruto = 0
          lancamentos.each do |lancamento|
            inss_11 += lancamento.valor if lancamento.imposto.descricao.include?('INSS 11% - PF')
            inss_20 += lancamento.valor if lancamento.imposto.descricao.include?('INSS 20% - PF')
            irrf_75 += lancamento.valor if lancamento.imposto.descricao.include?('I. R. 7,5% - PF')
            irrf_275 += lancamento.valor if lancamento.imposto.descricao.include?('I. R. 27,5% - PF')
            valor_bruto = lancamento.parcela.valor
            valor_liquido = lancamento.parcela.calcula_valor_total_da_parcela
          end
          xml.Row do
            xml.Cell { xml.Data conta.pessoa.nome, 'ss:Type'=>'String'}
            xml.Cell { xml.Data conta.numero_nota_fiscal_string, 'ss:Type'=>'String'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_bruto), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(inss_11), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(inss_20), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(irrf_75), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(irrf_275), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_liquido), 'ss:Type'=>'Number'}
          end

          total_inss_11 += inss_11
          total_inss_20 += inss_20
          total_irrf_75 += irrf_75
          total_irrf_275 += irrf_275
          total_bruto += valor_bruto
          total_liquido += valor_liquido
        end

        xml.Row do
          xml.Cell { }; xml.Cell { }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_bruto), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_inss_11), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_inss_20), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_irrf_75), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_irrf_275), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_liquido), 'ss:Type'=>'Number'}
        end
      else
        total_irrf_1 = 0; total_irrf_15 = 0; total_issqn_2 = 0; total_issqn_3 = 0; total_issqn_4 = 0; total_issqn_5 = 0; total_inss_pj_11 = 0; total_pis_cofins_465 = 0; total_bruto_pj = 0; total_liquido_pj = 0
        xml.Row do
          xml.Cell{};xml.Cell{};
          xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
        end

        xml.Row do
          xml.Cell { xml.Data 'Nome', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Doc/Nº', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'Valor Bruto', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'INSS 11%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'IRRF 1%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'IRRF 1.5%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'ISSQN 2%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'ISSQN 3%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'ISSQN 4%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'ISSQN 5%', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'PIS/COFINS', 'ss:Type'=>'String'}
          xml.Cell { xml.Data 'Líquido a Pagar', 'ss:Type'=>'String'}
        end

        xml.Row{}
        @lancamentos.each do |conta, lancamentos|
          irrf_1 = 0; irrf_15 = 0; issqn_2 = 0; issqn_3 = 0; issqn_4 = 0; issqn_5 = 0; inss_pj_11 = 0; pis_cofins_465 = 0; valor_bruto_pj = 0; valor_liquido_pj = 0
          lancamentos.each do |lancamento|
            inss_pj_11 += lancamento.valor if lancamento.imposto.descricao.include?('INSS 11% - PJ')
            irrf_1 += lancamento.valor if lancamento.imposto.descricao.include?('I.R R.F. 1% - PJ')
            irrf_15 += lancamento.valor if lancamento.imposto.descricao.include?('I.R R.F. 1,5% - PJ')
            issqn_2 += lancamento.valor if lancamento.imposto.descricao.include?('ISS 2%')
            issqn_3 += lancamento.valor if lancamento.imposto.descricao.include?('ISS 3%')
            issqn_4 += lancamento.valor if lancamento.imposto.descricao.include?('ISSQN 4%')
            issqn_5 += lancamento.valor if lancamento.imposto.descricao.include?('ISS 5%')
            pis_cofins_465 += lancamento.valor if lancamento.imposto.descricao.include?('PIS / COFINS / CSLL 4,65%')
            valor_bruto_pj = lancamento.parcela.valor
            valor_liquido_pj = lancamento.parcela.calcula_valor_total_da_parcela
          end
          xml.Row do
            xml.Cell { xml.Data conta.pessoa.nome, 'ss:Type'=>'String'}
            xml.Cell { xml.Data conta.numero_nota_fiscal_string, 'ss:Type'=>'String'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_bruto_pj), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(inss_pj_11), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(irrf_1), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(irrf_15), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(issqn_2), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(issqn_3), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(issqn_4), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(issqn_5), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(pis_cofins_465), 'ss:Type'=>'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_liquido_pj), 'ss:Type'=>'Number'}
          end

          total_inss_pj_11 += inss_pj_11
          total_irrf_1 += irrf_1
          total_irrf_15 += irrf_15
          total_issqn_2 += issqn_2
          total_issqn_3 += issqn_3
          total_issqn_4 += issqn_4
          total_issqn_5 += issqn_5
          total_pis_cofins_465 += pis_cofins_465
          total_bruto_pj += valor_bruto_pj
          total_liquido_pj += valor_liquido_pj
        end

        xml.Row do
          xml.Cell { }; xml.Cell { }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_bruto_pj), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_inss_pj_11), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_irrf_1), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_irrf_15), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_issqn_2), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_issqn_3), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_issqn_4), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_issqn_5), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_pis_cofins_465), 'ss:Type'=>'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_liquido_pj), 'ss:Type'=>'Number'}
        end
      end
    end
  end

end