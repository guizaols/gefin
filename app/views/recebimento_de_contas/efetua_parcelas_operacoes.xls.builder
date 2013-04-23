xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.Workbook({
    'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
    'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
    'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
    'xmlns:html' => "http://www.w3.org/TR/REC-html40",
    'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
  }) do

  xml.Worksheet 'ss:Name' => 'Envio ao DR' do
    xml.Table do

      xml.Row do
        #        xml.Cell { }
        #        xml.Cell { }
        #        xml.Cell { xml.Data 'Dados do Arquivo', 'ss:Type' => 'String' }
        #        xml.Cell { }
        #        xml.Cell { }

        xml.Cell { }
        xml.Cell { }
        xml.Cell { }
        xml.Cell { }
        xml.Cell { }
        xml.Cell { xml.Data 'Dados do Cliente', 'ss:Type' => 'String' }
        xml.Cell { }
        xml.Cell { }
        xml.Cell { }
        xml.Cell { }
        #        xml.Cell { }
        #        xml.Cell { }

        #        xml.Cell { }
        #        xml.Cell { }
        #        xml.Cell { }
        xml.Cell { }
        xml.Cell { }
        xml.Cell { xml.Data 'Dados do Contrato', 'ss:Type' => 'String' }
        xml.Cell { }
        xml.Cell { }
        #        xml.Cell { }
        #        xml.Cell { }
        #        xml.Cell { }
        #        xml.Cell { }
      end

      xml.Row do
        #        xml.Cell { xml.Data 'Identificador do Arquivo', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Código da Empresa', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Data Movimento', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Numero da Remessa', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Codigo Origem', 'ss:Type' => 'String' }

        #        xml.Cell { xml.Data 'Tipo Pessoa', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'CPF\\CNPJ', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Nome Cliente', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Endereço', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Número', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Bairro', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'CEP', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Cidade', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Estado (Sigla)', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Telefones', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Tel Celular', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Tel Residencial', 'ss:Type' => 'String' }

        #        xml.Cell { xml.Data 'Codigo Origem', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Cod Item Cobranca', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Item de Cobranca', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'DtContrato', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'DtVencimento', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'ValorParcela', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'ValorAtualizado', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'CorrecaoAutomatica', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Perc Multa', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Perc AD', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'NumUniOperacao', 'ss:Type' => 'String' }
        #        xml.Cell { xml.Data 'Servicos', 'ss:Type' => 'String' }

        xml.Cell { xml.Data 'Data do Início do Serviço', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Data Vencimento', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Valor Parcela', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Serviço', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Nº DE CONTROLE', 'ss:Type' => 'String' }
      end

      @parcelas_para_excel.each do |parcela|
        xml.Row do
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data Date.today.to_s_br, 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }

          pessoa = parcela.conta.pessoa
          #          xml.Cell { xml.Data pessoa.tipo_pessoa == 1 ? 'F' : 'J', 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.fisica? ? pessoa.cpf : pessoa.cnpj, 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.nome, 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.endereco, 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.numero, 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data pessoa.complemento, 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.bairro, 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.cep, 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.localidade ? pessoa.localidade.nome : nil, 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.localidade ? pessoa.localidade.uf : nil, 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.telefone[0], 'ss:Type' => 'String' }
          xml.Cell { xml.Data pessoa.telefone[1], 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data pessoa.telefone[3], 'ss:Type' => 'String' }

          #          xml.Cell { xml.Data parcela.id, 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcela.conta.data_inicio_servico, 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcela.data_vencimento, 'ss:Type' => 'String' }
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(parcela.valor), 'ss:Type' => 'Number' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'SIM', 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          #          xml.Cell { xml.Data 'N/A', 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcela.conta.servico.descricao, 'ss:Type' => 'String' }
          xml.Cell { xml.Data parcela.conta.numero_de_controle, 'ss:Type' => 'String' }
        end
      end
    end
  end
end
