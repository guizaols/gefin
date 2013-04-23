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
        xml.Cell {xml.Data "#{h Date::MONTHNAMES[params[:busca][:periodo_min].to_date.month.to_i].upcase} / #{session[:ano]}", 'ss:Type'=>'String'}
      end
      xml.Row do
  xml.Cell{};
    xml.Cell{};
      xml.Cell{};
        xml.Cell{};
          xml.Cell{};
            xml.Cell{};
              xml.Cell{};
               xml.Cell {xml.Data "Faturamento", 'ss:Type'=>'String'}
                xml.Cell{};
            
                xml.Cell {xml.Data "Clientes   ", 'ss:Type'=>'String'}
                xml.Cell{};
             
                xml.Cell {xml.Data "Receitas   ", 'ss:Type'=>'String'}

      end

      # Row
    
      total_saldo_final = 0
   

      xml.Row do
        xml.Cell {xml.Data "Número de Controle", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Data de Provisão", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Cliente", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Serviços", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Data de Cancelamento", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Data de Evasão", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Situação", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Valor - Contrato", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Débito", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Crédito", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Débito", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Crédito", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Débito", 'ss:Type'=>'String'}
        xml.Cell {xml.Data "Crédito", 'ss:Type'=>'String'}
      end

       total_geral_contratos = 0 
 total_faturamento_debito = 0 
 total_faturamento_credito = 0 
 total_clientes_debito = 0 
 total_clientes_credito = 0 
 total_receitas_debito = 0 
  total_receitas_credito = 0 


      @recebimentos.each do |grupo_servico, contas|
        valor_movimento = 0

        contas.each do |conta|
          contrato = RecebimentoDeConta.find(conta)
          ids_contas_rejeitadas = []
          total_saldo_final +=conta.valor_do_documento
          xml.Row do
            xml.Cell {xml.Data conta.numero_de_controle, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_inicio, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.pessoa.nome, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.servico.descricao, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_cancelamento, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.data_evasao, 'ss:Type'=>'String'}
            xml.Cell {xml.Data conta.situacao_fiemt_verbose, 'ss:Type'=>'String'}
            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(conta.valor_do_documento), 'ss:Type'=>'Number'}
            movimentos = Movimento.find(:all,:conditions=>["conta_id = ? AND conta_type= ? AND (tipo_lancamento = ? OR tipo_lancamento = ? OR tipo_lancamento = ? OR tipo_lancamento = ?) AND data_lancamento between ? AND ? ",conta.id,"RecebimentoDeConta","D","T", "V","O",@data,@data_final])


          faturamento_credito = 0 
         faturamento_debito = 0 

          array_dados = [] 
          movimentos.each do |movimento| 
          itens_movimentos = movimento.itens_movimentos 
          movimento.itens_movimentos.each do |item| 
             array_dados << ParametroContaValor.find_by_conta_contabil_id_and_unidade_id_and_tipo(item.plano_de_conta.id,conta.unidade.id,ParametroContaValor::FATURAMENTO) 
          end

           

        array_final_dados = []
         array_dados.each do |a| 
          unless a.blank? 
           array_final_dados << a 
           ids_contas_rejeitadas << a.conta_contabil_id 
          end
        end
         
          if array_final_dados.length > 0 
          p array_final_dados
            array_final_dados.each do |a| 
              movimento.itens_movimentos.each do |item|
               if (item.tipo == "D" && item.plano_de_conta_id.to_i == a.conta_contabil_id.to_i) 
               

                total_faturamento_debito+= item.valor 


                  faturamento_debito += (item.valor rescue 0) 
               elsif (item.tipo=="C" && item.plano_de_conta_id == a.conta_contabil_id) 
                  faturamento_credito += (item.valor rescue 0) 

                  total_faturamento_credito+= item.valor 
                end
              end


            end
           end
            array_dados = [] 
          
         end

        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(faturamento_debito), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(faturamento_credito), 'ss:Type'=>'Number'}

#####FIM FATURAMENTO

#inicio clientes

faturamento_credito = 0 
         faturamento_debito = 0 

          array_dados = [] 
         movimentos.each do |movimento| 
           
          movimento.itens_movimentos.each do |item| 
             array_dados << ParametroContaValor.find_by_conta_contabil_id_and_unidade_id_and_tipo(item.plano_de_conta.id,conta.unidade.id,ParametroContaValor::CLIENTES) 
          end

        array_final_dados = []
         array_dados.each do |a| 
            unless a.blank? 
           array_final_dados << a 
           ids_contas_rejeitadas << a.conta_contabil_id 
          end
        end
         
          if array_final_dados.length > 0 
            array_final_dados.each do |a| 
              movimento.itens_movimentos.each do |item|
               if item.tipo == 'D' && item.plano_de_conta.id == a.conta_contabil.id 
                 faturamento_debito += (item.valor rescue 0) 
                 total_clientes_debito+= item.valor 
           
                elsif item.tipo=='C' && item.plano_de_conta.id == a.conta_contabil.id 
                  faturamento_credito += (item.valor rescue 0) 
                  total_clientes_credito+= item.valor rescue 0 
                end
              end


            end
           end
           
         end 

        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(faturamento_debito), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(faturamento_credito), 'ss:Type'=>'Number'}

######Receitas
      
 faturamento_credito = 0 
         faturamento_debito = 0 

          array_dados = [] 
         movimentos.each do |movimento| 
           
         
         
          
              movimento.itens_movimentos.each do |item|
               if item.tipo == 'D' && !ids_contas_rejeitadas.include?(item.plano_de_conta.id) 
                 faturamento_debito += (item.valor rescue 0) 
                 total_receitas_debito+= item.valor 
           
                elsif item.tipo=='C' && !ids_contas_rejeitadas.include?(item.plano_de_conta.id) 
                  faturamento_credito += (item.valor rescue 0) 
                  total_receitas_credito+= item.valor 
                end
              end


           
         end

            xml.Cell {xml.Data preco_formatado_com_decimal_ponto(faturamento_debito), 'ss:Type'=>'Number'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(faturamento_credito), 'ss:Type'=>'Number'}











































          end
           total_geral_contratos += conta.valor_do_documento 
        end
      end

      xml.Row do
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {}
        xml.Cell {xml.Data 'Totalização', 'ss:Type'=>'String'}
        xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_saldo_final), 'ss:Type'=>'Number'}
         xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_faturamento_debito), 'ss:Type'=>'Number'}

 xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_faturamento_credito), 'ss:Type'=>'Number'}

 xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_clientes_debito), 'ss:Type'=>'Number'}
xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_clientes_credito), 'ss:Type'=>'Number'}
xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_receitas_debito), 'ss:Type'=>'Number'}
xml.Cell {xml.Data preco_formatado_com_decimal_ponto(total_receitas_credito), 'ss:Type'=>'Number'}




      end
    end
  end
end