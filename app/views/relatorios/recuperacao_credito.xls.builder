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

      meses = []; Parcela::MES.sort.each {|elemento| meses << elemento.last};
      array_auxiliar = []
      0.upto(12) do |i|
        array_auxiliar[i]= 0
      end
      
      xml.Row do
        xml.Cell {};xml.Cell {}; xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
        xml.Cell { xml.Data @titulo, 'ss:Type' => 'String'}
      end

      if params[:busca][:tipo_do_relatorio] == "0"

        array_a_receber = []; array_clone_a_receber = [];
        1.upto(12) do |i|
          array_a_receber <<  0
          array_clone_a_receber << "#{preco_formatado_com_decimal_ponto(0)}"
        end

        array_geral = []; array_clone_geral = []
        1.upto(12) do
          array_geral << 0
          array_clone_geral << "#{preco_formatado_com_decimal_ponto(0)}"
        end


        array_recebido = []; array_clone_recebido = [];
        1.upto(12) do
          array_recebido << 0
          array_clone_recebido << "#{preco_formatado_com_decimal_ponto(0)}"
        end


        inadimplentes = []; inadimplentes_clone=[]
        1.upto(12) do
          inadimplentes << 0
          inadimplentes_clone << "0"

        end

        rodape = []
        1.upto(12) do
          rodape << ""
        end

        @contas.each do |chave,elemento|

          if chave!= "anos_anteriores"
            array_a_receber[chave - 1] = elemento["a_receber"]
            array_recebido[chave - 1] = elemento["recebido"]
            array_geral[chave - 1] = elemento["geral"]
            inadimplentes[chave - 1] = elemento["inadimplencia"]
            inadimplentes_clone[chave-1] = "#{elemento["inadimplencia"]}"
            array_clone_a_receber[chave - 1] = "#{preco_formatado_com_decimal_ponto(elemento["a_receber"])}"
            array_clone_geral[chave - 1] = "#{preco_formatado_com_decimal_ponto(elemento["geral"])}"
            array_clone_recebido[chave - 1] = "#{preco_formatado_com_decimal_ponto(elemento["recebido"])}"
          end

        end


        xml.Row do
          xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
          xml.Cell { xml.Data "Exercício de #{params[:busca][:ano]}", 'ss:Type' => 'String'}
          xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
          xml.Cell {}
        end
      
        xml.Row do
          xml.Cell { xml.Data 'Totais', 'ss:Type' => 'String'}
          xml.Cell { xml.Data 'Anos Anteriores', 'ss:Type' => 'String'}
          meses.each do |mes|
            xml.Cell { xml.Data "#{mes}", 'ss:Type' => 'String'}
          end
          xml.Cell { xml.Data 'Total Ano', 'ss:Type' => 'String'}
          xml.Cell { xml.Data 'Total Geral', 'ss:Type' => 'String'}
        end

        xml.Row do
          xml.Cell { xml.Data "A RECEBER", 'ss:Type' => 'String'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(@contas["anos_anteriores"]["a_receber"]), 'ss:Type' => 'Number'}
          array_clone_a_receber.each do |valor|
            xml.Cell { xml.Data valor, 'ss:Type' => 'Number'}
          end
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(array_a_receber.sum), 'ss:Type' => 'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(@contas["anos_anteriores"]["a_receber"] + array_a_receber.sum), 'ss:Type' => 'Number'}
        end

        xml.Row do
          xml.Cell { xml.Data "RECEBIDO", 'ss:Type' => 'String'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(@contas["anos_anteriores"]["recebido"]), 'ss:Type' => 'Number'}
          array_clone_recebido.each do |valor|
            xml.Cell { xml.Data valor, 'ss:Type' => 'Number'}
          end
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(array_recebido.sum), 'ss:Type' => 'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(@contas["anos_anteriores"]["recebido"] + array_recebido.sum), 'ss:Type' => 'Number'}
        end

        xml.Row do
          xml.Cell { xml.Data "GERAL", 'ss:Type' => 'String'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(@contas["anos_anteriores"]["geral"]), 'ss:Type' => 'Number'}
          array_clone_geral.each do |valor|
            xml.Cell { xml.Data valor, 'ss:Type' => 'Number'}
          end
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(array_a_receber.sum + array_recebido.sum), 'ss:Type' => 'Number'}
          xml.Cell { xml.Data preco_formatado_com_decimal_ponto(array_geral.sum + @contas["anos_anteriores"]["geral"]), 'ss:Type' => 'Number'}
        end

        xml.Row do
          xml.Cell { xml.Data "INADIMPLENTES", 'ss:Type' => 'String'}
          xml.Cell { xml.Data @contas["anos_anteriores"]["inadimplencia"], 'ss:Type' => 'Number'}
          inadimplentes_clone.each do |valor|
            xml.Cell { xml.Data valor, 'ss:Type' => 'Number'}
          end
          xml.Cell { xml.Data "#{(array_a_receber.sum.to_f/(array_recebido.sum+array_a_receber.sum)*100).round(2)}", 'ss:Type' => 'Number'}
          xml.Cell { xml.Data "#{(((@contas["anos_anteriores"]["a_receber"] + array_a_receber.sum).to_f/(array_geral.sum + @contas["anos_anteriores"]["geral"]))*100).round(2)}", 'ss:Type' => 'Number'}
        end

      else
        xml.Row do
          xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
          xml.Cell { xml.Data "Exercício de #{params[:busca][:ano]}", 'ss:Type' => 'String'}
          xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
          xml.Cell {}
        end

        xml.Row do
          xml.Cell { xml.Data 'Atividades', 'ss:Type' => 'String'}
          xml.Cell { xml.Data 'Anos Anteriores', 'ss:Type' => 'String'}
          meses.each do |mes|
            xml.Cell { xml.Data "#{mes}", 'ss:Type' => 'String'}
          end
          xml.Cell { xml.Data 'Total Ano', 'ss:Type' => 'String'}
          xml.Cell { xml.Data 'Total Geral', 'ss:Type' => 'String'}
        end
        xml.Row {}
        xml.Row do
          xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
          xml.Cell { xml.Data "A RECEBER", 'ss:Type' => 'String'}
          xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
          xml.Cell {}
        end

        valortotal_a_receber = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        @contas['receber'].each do |elemento|
          xml.Row do
            xml.Cell { xml.Data elemento.first, 'ss:Type' => 'String'}
            elemento.last.each{|mes,valor|  if mes != "anos_anteriores";array_auxiliar[mes] = valor;valortotal_a_receber[mes]+=valor;else;array_auxiliar[0]=valor;valortotal_a_receber[0]+=valor;end}
            array_auxiliar.collect{|x| "#{preco_formatado_com_decimal_ponto(x)}" unless x.blank?}.each do |valor|
              xml.Cell { xml.Data valor, 'ss:Type' => 'Number'}
            end
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(array_auxiliar.compact.sum-array_auxiliar[0]), 'ss:Type' => 'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto((array_auxiliar.compact.sum-array_auxiliar[0])+array_auxiliar[0]), 'ss:Type' => 'Number'}
            valortotal_a_receber[13] += array_auxiliar.compact.sum-array_auxiliar[0]
            valortotal_a_receber[14] += (array_auxiliar.compact.sum-array_auxiliar[0])+array_auxiliar[0]
          end

          1.upto(12) do |i|
            array_auxiliar[i]= 0
          end
        end
        xml.Row do
          xml.Cell { xml.Data 'A RECEBER', 'ss:Type' => 'String'}
          valortotal_a_receber.each do |val_total|
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(val_total).untaint, 'ss:Type' => 'Number'}
          end
        end
        
        xml.Row {}
        xml.Row {}

        xml.Row do
          xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
          xml.Cell { xml.Data "RECEBIDO", 'ss:Type' => 'String'}
          xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {};xml.Cell {}
          xml.Cell {}
        end

        valortotal_recebido = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        @contas['recebido'].each do |elemento|
          xml.Row do
            xml.Cell { xml.Data elemento.first, 'ss:Type' => 'String'}
            elemento.last.each{|mes,valor|  if mes != "anos_anteriores";array_auxiliar[mes] = valor;valortotal_recebido[mes]+=valor;else;array_auxiliar[0]=valor;valortotal_recebido[0]+=valor;end}
            array_auxiliar.collect{|x| "#{preco_formatado_com_decimal_ponto(x)}" unless x.blank?}.each do |valor|
              xml.Cell { xml.Data valor, 'ss:Type' => 'Number'}
            end

            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(array_auxiliar.compact.sum-array_auxiliar[0]), 'ss:Type' => 'Number'}
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto((array_auxiliar.compact.sum-array_auxiliar[0])+array_auxiliar[0]), 'ss:Type' => 'Number'}
            valortotal_recebido[13] += array_auxiliar.compact.sum-array_auxiliar[0]
            valortotal_recebido[14] += (array_auxiliar.compact.sum-array_auxiliar[0])+array_auxiliar[0]
          end

          1.upto(12) do |i|
            array_auxiliar[i]= 0
          end
        end
        xml.Row do
          xml.Cell { xml.Data 'RECEBIDO', 'ss:Type' => 'String'}
          valortotal_recebido.each do |val_total|
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(val_total).untaint, 'ss:Type' => 'Number'}
          end
        end
        xml.Row {}
        xml.Row {}
        xml.Row do
          xml.Cell {xml.Data 'TOTAL GERAL' , 'ss:Type' => 'String'}
          valortotal_recebido.each_with_index do |val_total, key|
            xml.Cell { xml.Data preco_formatado_com_decimal_ponto(val_total + valortotal_a_receber[key]).untaint, 'ss:Type' => 'Number'}
          end
        end
      end
    end
  end
end