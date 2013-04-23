class ProjecoesController < ApplicationController

  before_filter :carrega_conta

  PERMISSOES = {
    'any' => Perfil::ManipularDadosDeRecebimentoDeContas
  }

$GAMBIARRA_MONSTRA ||={}


  def show
    if @conta.is_a?(RecebimentoDeConta) && @conta.servico_nao_iniciado?
      flash[:notice] = 'Não é permitido realizar projeções neste contrato, pois o serviço não foi iniciado.'
      redirect_to recebimento_de_conta_path(@conta)
    end
  end

  def gerar_relatorio
    if @conta.is_a?(RecebimentoDeConta) && @conta.servico_nao_iniciado?
      respond_to do |format|
        format.js do
          render :update do |page|
            page.alert 'Não é permitido realizar projeções neste contrato, pois o serviço não foi iniciado.'
            page.reload
          end
        end
        format.pdf do
          flash[:notice] = 'Não é permitido realizar projeções neste contrato, pois o serviço não foi iniciado.'
          redirect_to recebimento_de_conta_path(@conta)
        end
      end
    else
      respond_to do |format|
        format.js do
          $parcelas = params[:recebimento_de_conta][:parcelas].sort_by {|key, value| [value[:numero].to_i, key]}
          $parcelas.reject!{|key, value| value[:selecionada].blank?}
          render :update do |page|
            unless $parcelas.blank?
              page.new_window_to(:url => 'gerar_relatorio', :format => 'pdf')
            else
              page.alert("Selecione pelo menos uma Parcela.")
            end
          end
        end
        format.pdf do
          #        @parcelas = params[:recebimento_de_conta][:parcelas].sort_by {|key, value| [value[:numero], key]}
          $parcelas.collect{|key, parcela| parcela[:desconto_em_real] = ((parcela[:valor_da_multa_em_reais_original].real.to_f + parcela[:valor_dos_juros_em_reais_original].real.to_f) * (parcela[:desconto_em_porcentagem].real.to_f/100)).real.to_s}

          @totais = [
            $parcelas.collect{|key, parcela| (parcela[:preco_em_reais].real.to_f * 100).round}.sum,
            #$parcelas.collect{|key, parcela| (parcela[:valor_da_multa_em_reais].real.to_f * 100).round}.sum,
            #$parcelas.collect{|key, parcela| (parcela[:valor_dos_juros_em_reais].real.to_f * 100).round}.sum,
            $parcelas.collect{|key, parcela| (parcela[:valor_da_multa_em_reais_original].real.to_f * 100).round}.sum,
            $parcelas.collect{|key, parcela| (parcela[:valor_dos_juros_em_reais_original].real.to_f * 100).round}.sum,
            $parcelas.collect{|key, parcela| (parcela[:desconto_em_porcentagem].real.to_f).round}.sum,
            $parcelas.collect{|key, parcela| (parcela[:desconto_em_real].real.to_f * 100).round}.sum,
            $parcelas.collect{|key, parcela| (parcela[:valor_liquido_em_reais].real.to_f * 100).round}.sum
          ]

          render :layout => 'relatorio_horizontal'
        end
      end
    end
  end

  def renegociar
    parcelas_selecionadas = []
    parcelas_selecionadas = params[:recebimento_de_conta][:parcelas].sort_by {|key, value| [value[:numero].to_i, key]}
    p "sjdiajsdiajsdijasidjsi"
    $GAMBIARRA_MONSTRA = params[:recebimento_de_conta][:parcelas]
    p params[:recebimento_de_conta][:parcelas]

    parcelas_selecionadas.reject!{|key, value| value[:selecionada].blank?}
    if parcelas_selecionadas.blank?
      respond_to do |format|
        format.js do
          render :update do |page|
            page.alert 'Selecione ao menos uma parcela e calcule sua projeção!'
          end
        end
      end
    else
      if @conta.is_a?(RecebimentoDeConta) && @conta.servico_nao_iniciado?
        respond_to do |format|
          format.js do
            render :update do |page|
              page.alert 'Não é permitido renegociar este contrato, pois o serviço não foi iniciado.'
              page.reload
            end
          end
        end
      elsif @conta.is_a?(RecebimentoDeConta) && @conta.servico_iniciado?
        @parcela_para_renegociar = []
        @valor_parcelas = 0
        @historico = @conta.historico
        parcelas_selecionadas.each do |parcela_id, value|
          @parcela_para_renegociar << parcela_id
          @valor_parcelas += (value[:valor_liquido_em_reais].real.to_f * 100).round
        end
        respond_to do |format|
          format.js do
            render :update do |page|
              page << "Modalbox.show($('formulario_de_renegociacao'), {title: 'Renegociação', width:806, height:370, afterLoad: function(){#{page.replace_html 'formulario_de_renegociacao', :partial => 'recebimento_de_contas/renegociacao'}} });"
            end
          end
        end
      end
    end
  end

  def efetuar_renegociacao
    render :update do |page|
      if @conta.servico_nao_iniciado?
        page.alert 'Não é permitido renegociar este contrato, pois o serviço não foi iniciado.'
      else
        @conta.usuario_corrente = current_usuario
        params[:recebimento_de_conta][:usuario_renegociacao] = current_usuario
        mensagens = []
        mensagens << '* Insira um número de parcelas para a renegociação' if params[:numero_de_parcelas].blank?
        mensagens << '* Insira o dia para o vencimento das parcelas' if params[:recebimento_de_conta][:dia_do_vencimento].blank?
        mensagens << '* Insira um valor para a entrada' if params[:valor_da_entrada].blank?
        mensagens << '* O valor da entrada não pode ser superior ao valor do contrato' if ((params[:valor_da_entrada].real.to_f * 100).to_i) > ((params[:valor_parcelas_selec].real.to_f * 100).to_i)
        mensagens << '* O valor das parcelas a serem renegociadas deve estar preenchido' if params[:valor_parcelas_selec].blank?
        mensagens << '* O campo histórico deve ser preenchido' if params[:historico_renegociacao].blank?
        mensagens << '* O campo data da entrada deve ser preenchido' if params[:data_entrada].blank?
        mensagens << '* O campo data da entrada possui um valor inválido' if !params[:data_entrada].blank? && !['hoje', 'amanha'].include?(params[:data_entrada])

        if !mensagens.blank?
          page.alert mensagens.join("\n")
        else
          retorno = @conta.renegociar(params, session[:ano], params[:senha])
          if retorno.first
            page.alert retorno.last
            page << 'Modalbox.hide()'
            page << 'window.location.reload()'
          else
            if retorno[1] == 1
              page.alert retorno.last
              page << 'Element.show("tr_para_senha")'
            else
              page.alert retorno.last
            end
          end
        end
      end
    end
  end

  def termo_de_divida
    if @conta.is_a?(RecebimentoDeConta) && @conta.servico_nao_iniciado?
      respond_to do |format|
        format.js do
          render :update do |page|
            page.alert 'Não é permitido realizar projeções neste contrato, pois o serviço não foi iniciado.'
            page.hide :loading_renegociacao
            page.reload
          end
        end
        format.pdf do
          flash[:notice] = 'Não é permitido realizar projeções neste contrato, pois o serviço não foi iniciado.'
          redirect_to recebimento_de_conta_path(@conta)
        end
      end
    else
      respond_to do |format|
        format.js do
          @unidade = Unidade.find(session[:unidade_id])
          mensagem = []
          mensagem << "Preencha o campo Nome do Gerente da Unidade." if @unidade.responsavel.blank?
          mensagem << "Preencha o campo CPF do Gerente da Unidade." if @unidade.responsavel_cpf.blank?
          mensagem << "Nenhuma parcela foi renegociada! Impossível gerar o termo de confissão de dívida!" if $parcelas_sendo_renegociadas.blank?
          render :update do |page|
            if mensagem.blank?
              page.new_window_to(:url => 'termo_de_divida', :format => 'print')
            else
              page.alert mensagem.join("\n")
            end
          end
        end
        format.print do
          @user = current_usuario
          @conta = RecebimentoDeConta.find(params[:recebimento_de_conta_id])
          #@parcelas = @conta.parcelas_em_aberto_ordenadas
          #@parcelas = $novas_parcelas_da_renegociacao[@conta.id]
          #@parcelas_renegociadas = @conta.parcelas_renegociadas
          @parcelas_renegociadas = []
          p "**************************************************************"
          p $parcelas_sendo_renegociadas.length
          $parcelas_sendo_renegociadas[@conta.id].each do |k, v|
            @parcelas_renegociadas << Parcela.find(k)
          end
          
          @parcelas_selecionadas = []
          $novas_parcelas_da_renegociacao[@conta.id].each do |x, i|
            @parcelas_selecionadas << Parcela.find(x)
          end
          @unidade = Unidade.find(session[:unidade_id])
          render :layout => 'termo_de_divida'
        end
      end
    end
  end

  def update
    render :update do |page|
      if @conta.is_a?(RecebimentoDeConta) && @conta.servico_nao_iniciado?
        page.alert 'Não é permitido realizar projeções neste contrato, pois o serviço não foi iniciado.'
        page.hide :loading_renegociacao
        page.reload
      else
        if params[:acao] == 'Calcular'
          #          $parcela_para_renegociar = {}
          numero_das_parcelas_que_estao_com_data_menor = []
          total_indices = 0
          total_parcelas = 0
          total_geral = 0
          total_juros = 0
          total_multas = 0
          total_desconto_percentual = 0
          total_desconto_real = 0
          total_juros_selecionadas = 0
          total_multas_selecionadas = 0
          total_desconto_percentual_selecionadas = 0
          total_desconto_real_selecionadas = 0
          desconto_percentual_universal = params[:desconto_percentual_universal].to_f
          desconto_para_retirar_do_total = 0
          total_selecionado = 0
          $checadas_quando_calculada_proporcao = false
          params[:recebimento_de_conta][:parcelas].each do |parcela_id, campos|
            campos[:desconto_em_porcentagem] = desconto_percentual_universal if desconto_percentual_universal && desconto_percentual_universal > 0
            @parcela = Parcela.find_by_id_and_conta_id(parcela_id, @conta.id)
            if (campos[:data_vencimento] == @parcela.data_vencimento) || (campos[:data_vencimento].to_date >= Date.today)
              if campos[:selecionada] == '1'
                $checadas_quando_calculada_proporcao = true
                total_selecionado += campos[:preco_em_reais].to_f
                @parcela.indice = campos[:indice]
                @parcela.selecionada = campos[:selecionada]
                @parcela.data_vencimento = campos[:data_vencimento]
                @parcela.desconto_em_porcentagem = campos[:desconto_em_porcentagem]
                @parcela.percentual_de_desconto = (campos[:desconto_em_porcentagem].to_f * 100.0).to_i
                @parcela.calcular_juros_e_multas!(params[:data_base])
                @parcela.valor_apos_ser_calculado = (@parcela.calcula_valor_total_da_parcela + @parcela.retorna_valor_de_correcao_pelo_indice)
                @parcela.ax_multa = @parcela.valor_da_multa
                @parcela.ax_juros = @parcela.valor_dos_juros
                # Calcula % desconto em cima dos juros e multas
                valor_dos_juros_em_reais_com_desconto = 0
                valor_da_multa_em_reais_com_desconto = 0
                if @parcela.desconto_em_porcentagem && (@parcela.desconto_em_porcentagem.to_f >= 0 && @parcela.desconto_em_porcentagem.to_f <= 100)
                  valor_dos_juros_em_reais_com_desconto = ((@parcela.valor_dos_juros.to_f * @parcela.desconto_em_porcentagem.to_f)/ 100).round(1)
# se der merda trocar para round(2)
                  valor_da_multa_em_reais_com_desconto = (@parcela.valor_da_multa.to_f * @parcela.desconto_em_porcentagem.to_f).round(0) / 100.0

                  valor_dos_juros_em_reais_sem_desconto = @parcela.valor_dos_juros
                  valor_da_multa_em_reais_sem_desconto = @parcela.valor_da_multa
                  valor_com_desconto_em_reais = (valor_dos_juros_em_reais_com_desconto + valor_da_multa_em_reais_com_desconto)
                  valor_sem_desconto_em_reais = (valor_dos_juros_em_reais_sem_desconto + valor_da_multa_em_reais_sem_desconto)
                  @parcela.valor_dos_juros = @parcela.valor_dos_juros.to_f - valor_dos_juros_em_reais_com_desconto
                  @parcela.valor_da_multa = @parcela.valor_da_multa.to_f - valor_da_multa_em_reais_com_desconto
                  p "Valor da Multa"
                  p valor_da_multa_em_reais_com_desconto
                  p "Valor Dos Juros"
                  p valor_dos_juros_em_reais_com_desconto
p "Valor Documento"
p @parcela.valor_apos_ser_calculado
                  @parcela.valor_apos_ser_calculado = @parcela.valor_apos_ser_calculado - valor_com_desconto_em_reais
                else
                  @parcela.desconto_em_porcentagem = '0,00'
                  valor_dos_juros_em_reais_com_desconto = (@parcela.valor_dos_juros.to_f * @parcela.desconto_em_porcentagem.to_f).round / 100.0
                  valor_da_multa_em_reais_com_desconto = (@parcela.valor_da_multa.to_f * @parcela.desconto_em_porcentagem.to_f).round / 100.0
                  valor_dos_juros_em_reais_sem_desconto = @parcela.valor_dos_juros
                  valor_da_multa_em_reais_sem_desconto = @parcela.valor_da_multa
                  valor_com_desconto_em_reais = (valor_dos_juros_em_reais_com_desconto + valor_da_multa_em_reais_com_desconto)
                  valor_sem_desconto_em_reais = (valor_dos_juros_em_reais_sem_desconto + valor_da_multa_em_reais_sem_desconto)
                  @parcela.valor_dos_juros = @parcela.valor_dos_juros.to_f - valor_dos_juros_em_reais_com_desconto
                  @parcela.valor_da_multa = @parcela.valor_da_multa.to_f - valor_da_multa_em_reais_com_desconto
                  @parcela.valor_apos_ser_calculado = @parcela.valor_apos_ser_calculado - valor_com_desconto_em_reais
                end
                # Atribui o valor calculado do índice para esta parcela
                total_indices += @parcela.retorna_valor_de_correcao_pelo_indice
                # Atribui no total das parcelas porém sem o índice
                total_parcelas += @parcela.calcula_valor_total_da_parcela + @parcela.retorna_valor_de_correcao_pelo_indice
                # Atribui no geral com o índice
                total_geral += @parcela.calcula_valor_total_da_parcela + @parcela.retorna_valor_de_correcao_pelo_indice
                # Atribuindo para listar nos campos de selecionadas e não selecionadas
                total_juros += @parcela.valor_dos_juros
                total_juros_selecionadas += @parcela.valor_dos_juros
                # Atribuindo para listar nos campos de selecionadas e não selecionadas
                total_multas += @parcela.valor_da_multa
                total_multas_selecionadas += @parcela.valor_da_multa
                # Atribuindo para listar nos campos de selecionadas e não selecionadas
                total_desconto_percentual += @parcela.desconto_em_porcentagem.to_f
                total_desconto_percentual_selecionadas += @parcela.desconto_em_porcentagem.to_f
                # Atribuindo para listar nos campos de selecionadas e não selecionadas
                if valor_com_desconto_em_reais > 0
                  total_desconto_real += valor_com_desconto_em_reais
                  total_desconto_real_selecionadas += valor_com_desconto_em_reais
                end

                #$parcela_para_renegociar[@parcela.id] = @parcela.valor_apos_ser_calculado

              else
                $checadas_quando_calculada_proporcao = false
                # Aqui será calculado e atribuido, porém so para os valores gerais e não selecionados
                # Nessa seção são será calculado o desconto para a parcela, nem alterações na data de vencimento
                @parcela.calcular_juros_e_multas!(params[:data_base])
                @parcela.valor_apos_ser_calculado = (@parcela.calcula_valor_total_da_parcela + @parcela.retorna_valor_de_correcao_pelo_indice)
                total_juros += @parcela.valor_dos_juros
                total_multas += @parcela.valor_da_multa
                total_geral += (@parcela.valor + @parcela.valor_dos_juros + @parcela.valor_da_multa)
                total_desconto_percentual += campos[:desconto_em_porcentagem].to_f

                # Calculo dos valores de desconto
                nova_parcela = @parcela.dup
                nova_parcela.desconto_em_porcentagem = campos[:desconto_em_porcentagem]
                nova_parcela.percentual_de_desconto = (campos[:desconto_em_porcentagem].to_f * 100.0).to_i
                nova_parcela.calcular_juros_e_multas!(params[:data_base])

                valor_dos_juros_em_reais_com_desconto = (nova_parcela.valor_dos_juros.to_f * nova_parcela.desconto_em_porcentagem.to_f).round / 100.0
                valor_da_multa_em_reais_com_desconto = (nova_parcela.valor_da_multa.to_f * nova_parcela.desconto_em_porcentagem.to_f).round / 100.0
                valor_dos_juros_em_reais_sem_desconto = nova_parcela.valor_dos_juros
                valor_da_multa_em_reais_sem_desconto = nova_parcela.valor_da_multa
                valor_com_desconto_em_reais = (valor_dos_juros_em_reais_com_desconto + valor_da_multa_em_reais_com_desconto)
                valor_sem_desconto_em_reais = (valor_dos_juros_em_reais_sem_desconto + valor_da_multa_em_reais_sem_desconto)

                if valor_com_desconto_em_reais > 0
                  total_desconto_real += (valor_sem_desconto_em_reais - valor_com_desconto_em_reais)
                  desconto_para_retirar_do_total += (valor_sem_desconto_em_reais - valor_com_desconto_em_reais)
                end
              end
            else
              # Apesar da data estar errada, ele calcula como se a parcela não tivesse sido escolhida
              numero_das_parcelas_que_estao_com_data_menor << @parcela.numero
              page << "$('parcela_#{@parcela.id}_checkbox').checked = false"
              page << "$('parcela_#{@parcela.id}_data_vencimento').value = '#{@parcela.data_vencimento}'"
              page << "$('parcela_#{@parcela.id}_data_vencimento').readOnly = true"
              @parcela.calcular_juros_e_multas!(params[:data_base])
              @parcela.valor_apos_ser_calculado = (@parcela.calcula_valor_total_da_parcela + @parcela.retorna_valor_de_correcao_pelo_indice)
              total_juros += @parcela.valor_dos_juros
              total_multas += @parcela.valor_da_multa
              total_geral += (@parcela.valor + @parcela.valor_dos_juros + @parcela.valor_da_multa)
              valor_dos_juros_em_reais_com_desconto = (nova_parcela.valor_dos_juros.to_f * nova_parcela.desconto_em_porcentagem.to_f).round / 100.0
              valor_da_multa_em_reais_com_desconto = (nova_parcela.valor_da_multa.to_f * nova_parcela.desconto_em_porcentagem.to_f).round / 100.0
              valor_dos_juros_em_reais_sem_desconto = @parcela.valor_dos_juros
              valor_da_multa_em_reais_sem_desconto = @parcela.valor_da_multa
              valor_com_desconto_em_reais = (valor_dos_juros_em_reais_com_desconto + valor_da_multa_em_reais_com_desconto)
              valor_sem_desconto_em_reais = (valor_dos_juros_em_reais_sem_desconto + valor_da_multa_em_reais_sem_desconto)
              total_desconto_percentual += @parcela.desconto_em_porcentagem.to_f
              if valor_com_desconto_em_reais > 0
                total_desconto_real += (valor_sem_desconto_em_reais - valor_com_desconto_em_reais)
              end
            end
            page << "classe = $('parcela_#{parcela_id}').className"
            page.replace "parcela_#{parcela_id}", :partial => 'parcela', :object => @parcela, :locals => {:inicial => false}
            page << "$('parcela_#{parcela_id}').addClassName(classe)"
          end

          page.hide :loading_renegociacao
        
          #          page[:total_parcelas_selecionadas].value = total_selecionado
          #          page << "$('total_parcelas_selecionadas').onblur();"

          page[:total_indices].value = total_indices.round / 100.0
          page << "$('total_indices').onblur();"

          page[:total_parcelas].value = total_parcelas.round / 100.0
          page << "$('total_parcelas').onblur();"

          page[:total_juros].value = total_juros.round / 100.0
          page << "$('total_juros').onblur();"

          page[:total_juros_selecionadas].value = total_juros_selecionadas.round / 100.0
          page << "$('total_juros_selecionadas').onblur();"

          page[:total_multas].value = total_multas.round / 100.0
          page << "$('total_multas').onblur();"

          page[:total_multas_selecionadas].value = total_multas_selecionadas.round / 100.0
          page << "$('total_multas_selecionadas').onblur();"

          #          page[:total_desconto_percentual].value = total_desconto_percentual
          #          page << "$('total_desconto_percentual').onblur();"

          #          page[:total_desconto_percentual_selecionadas].value = total_desconto_percentual_selecionadas
          #          page << "$('total_desconto_percentual_selecionadas').onblur();"

          page[:total_desconto_real].value = total_desconto_real / 100
          page << "$('total_desconto_real').onblur();"

          page[:total_desconto_real_selecionadas].value = total_desconto_real_selecionadas / 100
          page << "$('total_desconto_real_selecionadas').onblur();"

          total_geral -= desconto_para_retirar_do_total

          page[:total_geral].value = total_geral.round / 100.0
          page << "$('total_geral').onblur();"

          if numero_das_parcelas_que_estao_com_data_menor.length > 0
            page.alert("Foi especificado uma data de vencimento menor que #{Date.today.to_s_br} para as parcelas #{numero_das_parcelas_que_estao_com_data_menor.join(', ')}.")
          end
        elsif params[:acao] == 'Aplicar'
          resultado_da_funcao = Parcela.aplicar_projecao(@conta.id, params[:recebimento_de_conta], current_usuario)
          page.hide :loading_renegociacao
          page.alert resultado_da_funcao.last
          page.reload
        end
      end
    end
    #    render :update do |page|
    #      total_indices = 0
    #      total_parcelas = 0
    #      total_geral = 0
    #      params[:recebimento_de_conta][:parcelas].each do |parcela_id, campos|
    #        if campos[:selecionada] == '1'
    #          @parcela = Parcela.find_by_id_and_conta_id(parcela_id, @conta.id)
    #          @parcela.indice = campos[:indice].real.to_f
    #          @parcela.selecionada = campos[:selecionada]
    #          @parcela.calcular_juros_e_multas!(params[:data_base])
    #          page.replace "parcela_#{parcela_id}", :partial => 'parcela', :object => @parcela
    #          page.visual_effect :highlight, "parcela_#{parcela_id}"
    #          total_indices += @parcela.retorna_valor_de_correcao_pelo_indice
    #          total_parcelas += @parcela.calcula_valor_total_da_parcela
    #          total_geral += @parcela.calcula_valor_total_da_parcela + @parcela.retorna_valor_de_correcao_pelo_indice
    #        end
    #      end
    #      page.call :atualiza_cores_das_trs_de_listagem
    #      page.hide :loading_projecao
    #
    #      page[:total_indices].value = total_indices.round / 100.0
    #      page << "$('total_indices').onblur();"
    #
    #      page[:total_parcelas].value = total_parcelas.round / 100.0
    #      page << "$('total_parcelas').onblur();"
    #
    #      page[:total_geral].value = total_geral.round / 100.0
    #      page << "$('total_geral').onblur();"
    #    end
  end

end
