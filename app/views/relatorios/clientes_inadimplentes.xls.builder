xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Clientes Inadimplentes' do
    xml.Table do

      xml.Row do
        xml.Cell{};xml.Cell{};
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end

      total_original = 0; total_descontos = 0; total_acrescimos = 0; total_geral = 0
      @contas_receber.each do |pessoa,contas|

        # Header
        xml.Row do
          xml.Cell { xml.Data 'Responsável:', 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'CPF', 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.cpf, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Endereço', 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.endereco, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'E-mail', 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.email.first, 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Telefone 1', 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.telefone[0], 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Telefone 2', 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.telefone[1], 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Telefone 3', 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.telefone[2], 'ss:Type' => 'String' }
        end

        contas.each do |conta|
          xml.Row do
            if !conta.dependente.blank?
              xml.Cell { xml.Data 'Dependente:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.dependente.nome, 'ss:Type' => 'String' }
            else
              xml.Cell { xml.Data 'Sem dependente cadastrado', 'ss:Type' => 'String' }
            end
            xml.Cell { xml.Data ' Tel. Aluno:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.pessoa.telefone.first, 'ss:Type' => 'String' }
            if !conta.dependente.blank?
              xml.Cell { xml.Data 'Pai:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.dependente.nome_do_pai, 'ss:Type' => 'String' }
            else
              xml.Cell { xml.Data 'Pai:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Sem dependente cadastrado', 'ss:Type' => 'String' }
            end
            if !conta.dependente.blank?
              xml.Cell { xml.Data 'Mãe:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data conta.dependente.nome_da_mae, 'ss:Type' => 'String' }
            else
              xml.Cell { xml.Data 'Mãe:', 'ss:Type' => 'String' }
              xml.Cell { xml.Data 'Sem dependente cadastrado', 'ss:Type' => 'String' }
            end
          end

          valor_original = 0; valor_acrescimos = 0; valor_desconto = 0; valor_total = 0

          @parcelas = []
          conta.parcelas.each{|parcela| @parcelas << parcela if (parcela.data_da_baixa.blank?) && (Date.today > parcela.data_vencimento.to_date) }
          xml.Row do
            xml.Cell { xml.Data '', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Turma', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Nº Parcela', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Vencimento', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Atraso', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Valor orig.', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Total desc.', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Total acres.', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Valor Total.', 'ss:Type' => 'String' }
          end
          @parcelas.each do |parcela|
            xml.Row do
              xml.Cell { xml.Data parcela.situacao_verbose, 'ss:Type' => 'String' }
              xml.Cell { }
              xml.Cell { xml.Data parcela.numero, 'ss:Type' => 'Number' }
              xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
              xml.Cell { xml.Data "#{(Date.today - parcela.data_vencimento.to_date).to_i}", 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_do_desconto), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor_dos_juros + parcela.valor_da_multa + parcela.honorarios + parcela.taxa_boleto + parcela.protesto + parcela.outros_acrescimos), 'ss:Type' => 'Number' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto((parcela.valor + parcela.valor_dos_juros + parcela.valor_da_multa + parcela.honorarios + parcela.taxa_boleto + parcela.protesto + parcela.outros_acrescimos) - parcela.valor_do_desconto), 'ss:Type' => 'Number' }
            end
            valor_original += parcela.valor
            valor_acrescimos += (parcela.valor_dos_juros + parcela.valor_da_multa + parcela.honorarios + parcela.taxa_boleto + parcela.protesto + parcela.outros_acrescimos)
            valor_desconto += parcela.valor_do_desconto
            valor_total += (parcela.valor + parcela.valor_dos_juros + parcela.valor_da_multa + parcela.honorarios + parcela.taxa_boleto + parcela.protesto + parcela.outros_acrescimos) - parcela.valor_do_desconto
          end
          xml.Row do
            xml.Cell { xml.Data '', 'ss:Type' => 'String' }
            xml.Cell { xml.Data '', 'ss:Type' => 'String' }
            xml.Cell { xml.Data '', 'ss:Type' => 'String' }
            xml.Cell { xml.Data '', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'TOTAL DO RESPONSÁVEL:', 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_original), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_desconto), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_acrescimos), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_total), 'ss:Type' => 'Number' }
          end

          total_original += valor_original
          total_descontos += valor_desconto
          total_acrescimos += valor_acrescimos
          total_geral += valor_total
        end
        xml.Row do
              xml.Cell { }
        end
      end

      xml.Row do
        xml.Cell { xml.Data '', 'ss:Type' => 'String' }
        xml.Cell { xml.Data '', 'ss:Type' => 'String' }
        xml.Cell { xml.Data '', 'ss:Type' => 'String' }
        xml.Cell { xml.Data '', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'TOTAL GERAL:', 'ss:Type' => 'String' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_original), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_descontos), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_acrescimos), 'ss:Type' => 'Number' }
        xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_geral), 'ss:Type' => 'Number' }
      end
    end
  end
end