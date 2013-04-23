xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'HISTÓRICO DO CLIENTE' do
    xml.Table do

      xml.Row do
        xml.Cell{}; xml.Cell{}
        xml.Cell {xml.Data @titulo, 'ss:Type'=>'String'}
      end
      if params[:busca][:relatorio] == 'simplificado'
        # Header
        xml.Row do
          xml.Cell { xml.Data 'Documento', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Número de Controle', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Valor do Contrato', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Valor Recebido', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Saldo', 'ss:Type' => 'String' }
        end

        total_documentos = 0
        total_valores_recebidos = 0
        total_saldo = 0

        @parcelas.each do |conta, parcelas|
          saldo = 0
          #valor_recebido = conta.parcelas.collect{|parc| parc.situacao == Parcela::QUITADA && parc.data_da_baixa.to_date < params[:busca][:data].to_date ? parc.valor : 0}.sum
          valor_recebido = conta.parcelas.collect{|parc| parc.situacao == Parcela::QUITADA && parc.data_da_baixa.to_date < params[:busca][:periodo_max].to_date ? parc.valor : 0}.sum
        #  saldo = (conta.valor_do_documento - valor_recebido)
          movimento = Movimento.find_by_conta_id_and_conta_type_and_tipo_lancamento_and_provisao(conta.id,'RecebimentoDeConta','S','1') rescue 0
          saldo = (movimento.valor_total - valor_recebido) rescue 0
          







          xml.Row do
            xml.Cell { xml.Data conta.numero_nota_fiscal, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.numero_de_controle, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.pessoa.fisica? ? conta.pessoa.nome : conta.pessoa.razao_social, 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto((movimento.valor_total)rescue 0), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_recebido), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(saldo), 'ss:Type' => 'Number' }
           # total_documentos += conta.valor_do_documento
             total_documentos += movimento.valor_total rescue 0
           
            total_valores_recebidos += valor_recebido
            total_saldo += saldo








          end
        end
        xml.Row do
          xml.Cell{}; xml.Cell{}; xml.Cell{};
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_documentos), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_valores_recebidos), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_saldo), 'ss:Type' => 'Number' }
        end
      else
        total_documentos = 0; total_valores_recebidos = 0; total_saldo = 0
        @parcelas.each do |conta, parcelas|
          saldo = 0
          valor_recebido = conta.parcelas.collect{|parc| parc.situacao == Parcela::QUITADA && parc.data_da_baixa.to_date < params[:busca][:data].to_date ? parc.valor : 0}.sum
          saldo = (conta.valor_do_documento - valor_recebido)
          total_documentos += conta.valor_do_documento
          total_valores_recebidos += valor_recebido
          total_saldo += saldo
          xml.Row do
            xml.Cell { xml.Data 'Documento', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Número de Controle', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Valor do Contrato', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Valor Recebido', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Saldo', 'ss:Type' => 'String' }
          end
          xml.Row do
            xml.Cell { xml.Data conta.numero_nota_fiscal, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.numero_de_controle, 'ss:Type' => 'String' }
            xml.Cell { xml.Data conta.pessoa.fisica? ? conta.pessoa.nome : conta.pessoa.razao_social, 'ss:Type' => 'String' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(conta.valor_do_documento), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_recebido), 'ss:Type' => 'Number' }
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(saldo), 'ss:Type' => 'Number' }
          end
          xml.Row do
            xml.Cell{}; xml.Cell{}; xml.Cell { xml.Data 'PARCELAS', 'ss:Type' => 'String'}
          end
          xml.Row do
            xml.Cell { xml.Data 'Número', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Data de Vencimento', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Valor', 'ss:Type' => 'String' }
            xml.Cell { xml.Data 'Data da Baixa', 'ss:Type' => 'String' }
          end
          parcelas.each do |parcela|
            valor_liquido_percela = parcela.valor + parcela.valor_dos_juros + parcela.valor_da_multa + parcela.valores_novos_recebimentos + parcela.outros_acrescimos - parcela.soma_impostos_da_parcela - parcela.valor_do_desconto
            xml.Row do
              xml.Cell { xml.Data parcela.parcela_mae_id.blank? ? parcela.numero : parcela.numero_parcela_filha, 'ss:Type' => 'String' }
              xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
              xml.Cell { xml.Data preco_formatado_com_decimal_ponto(valor_liquido_percela), 'ss:Type' => 'Number' }
              if !parcela.data_da_baixa.blank? && Date.today >= parcela.data_da_baixa.to_date
                xml.Cell { xml.Data parcela.data_da_baixa, 'ss:Type' => 'String' }
              else
                xml.Cell{}
              end
            end
          end
        end
        xml.Row do
          xml.Cell{}; xml.Cell{}
        end
        xml.Row do
          xml.Cell { xml.Data 'Total Valores Contratos', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Total Valores Recebidos', 'ss:Type' => 'String' }
          xml.Cell { xml.Data 'Saldo Total', 'ss:Type' => 'String' }
        end
        xml.Row do
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_documentos), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_valores_recebidos), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(total_saldo), 'ss:Type' => 'Number' }
        end
      end
    end
  end
end
