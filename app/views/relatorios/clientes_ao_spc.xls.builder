xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Clientes ao SPC' do
    xml.Table do

      # Header
      xml.Row do
        xml.Cell { xml.Data 'Cliente', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Dependentes', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'CPF/CNPJ', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Endereco', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Localidade', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Curso/Atividade', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor em Atraso', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Nº de Parcelas Devedoras', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Vencimento da Parcela', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data do Início do Contrato', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data de Emissão de Carta 1', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data de Emissão de Carta 2', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data de Emissão de Carta 3', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Número de Controle', 'ss:Type' => 'String' }
      end

      # Rows
      @parcelas.group_by {|parcela| parcela.conta}.each_pair do |recebimento_de_conta, parcelas|
        cliente = recebimento_de_conta.pessoa rescue 'Pessoa Excluída'
        xml.Row do
          xml.Cell { xml.Data cliente.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data recebimento_de_conta.dependente ? recebimento_de_conta.dependente.nome : '' , 'ss:Type' => 'String' }
          xml.Cell { xml.Data cliente.fisica? ? cliente.cpf : cliente.cnpj, 'ss:Type' => 'String' }
          xml.Cell { xml.Data "#{cliente.endereco}, #{cliente.bairro}", 'ss:Type' => 'String' }
          xml.Cell { xml.Data cliente.localidade ? "#{cliente.localidade.nome}" : '', 'ss:Type' => 'String' }
          xml.Cell { xml.Data recebimento_de_conta.servico.descricao, 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcelas.sum(&:valor)), 'ss:Type' => 'Number' }
          xml.Cell { xml.Data parcelas.length, 'ss:Type' => 'Number' }
          xml.Cell { xml.Data recebimento_de_conta.dia_do_vencimento, 'ss:Type' => 'Number' }
          xml.Cell { xml.Data recebimento_de_conta.data_inicio, 'ss:Type' => 'String' }
          xml.Cell { xml.Data recebimento_de_conta.data_primeira_carta, 'ss:Type' => 'String' }
          xml.Cell { xml.Data recebimento_de_conta.data_segunda_carta, 'ss:Type' => 'String' }
          xml.Cell { xml.Data recebimento_de_conta.data_terceira_carta, 'ss:Type' => 'String' }
          xml.Cell { xml.Data recebimento_de_conta.numero_de_controle, 'ss:Type' => 'String' }
        end
      end
    end
  end
end
