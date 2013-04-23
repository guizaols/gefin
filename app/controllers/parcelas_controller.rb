class ParcelasController < ApplicationController

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDasParcelas,
    'any' => Perfil::Parcelas,
    ['gravar_rateio', 'gravar_imposto', 'atualiza_juros', 'gravar_baixa', 'estornar_parcela_baixa',
      'listar_recibos', 'imprimir_recibos', 'cancelar', 'gerar_boletos', 'baixa_parcial'
    ] => Perfil::ManipularDadosDasParcelas,
    'baixa_dr' => Perfil::BaixaDr
  }

  before_filter :nao_pode_alterar_parcelas_de_um_contrato_com_situacao_fiemt_inativo,
    :except => [:listar_recibos, :imprimir_recibos, :baixa, :gerar_rateio]
  before_filter :carrega_conta, :carrega_entidade
  before_filter :verifica_se_pode_acessar_rateio, :only => [:gerar_rateio, :gravar_rateio]
  before_filter :verifica_se_parcela_esta_cancelada,
    :only => [:gerar_rateio, :gravar_rateio, :lancar_impostos_na_parcela, :gravar_imposto, :baixa, :gravar_baixa,
    :estornar_parcela_baixada]
  before_filter :verificando_situacao_contrato,
    :only => [:gravar_rateio, :lancar_impostos_na_parcela, :gravar_imposto, :gravar_baixa,
    :estornar_parcela_baixada]
  before_filter :verifica_se_parcela_esta_renegociada,
    :only => [:gerar_rateio, :gravar_rateio, :lancar_impostos_na_parcela, :gravar_imposto, :baixa, :gravar_baixa,
    :estornar_parcela_baixada]

  def gerar_rateio
    @parcela = @conta.parcelas.find(params[:id])
  end
 
  def gravar_rateio
    @parcela = @conta.parcelas.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    params[:dados_do_rateio].blank? ? @parcela.dados_do_rateio = {} : @parcela.dados_do_rateio = params[:dados_do_rateio]
    params[:replicar_para_todos] == "1" ? @parcela.replicar = true : @parcela.replicar = false
    retorno = @parcela.grava_itens_do_rateio(session[:ano], current_usuario)
    if retorno.first == true
      flash[:notice] = retorno.last
      redireciona_para_conta
    else
      flash.now[:notice] = "Não foi possível gravar o rateio!\n\n#{retorno.last}"
      render :action => "gerar_rateio"
    end
  end
  
  def lancar_impostos_na_parcela
    @parcela = @conta.parcelas.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    unless @parcela.dados_do_imposto.blank?
      @parcela.dados_do_imposto.each do |indice, item|
        @parcela.dados_do_imposto[indice.to_s]['valor_imposto'] = @parcela.dados_do_imposto[indice.to_s]['valor_imposto'].real.to_s
      end
    end
  end
  
  def gravar_imposto
    @parcela = @conta.parcelas.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    @parcela.dados_do_imposto = params[:dados_do_imposto] || {}
    retorno = @parcela.grava_dados_do_imposto_na_parcela(session[:ano], current_usuario)
    if retorno.first
      flash[:notice] = retorno.last
      redireciona_para_conta
    else
      flash.now[:notice] = "Não foi possível salvar os dados da parcela!\n#{retorno.last}"
      render :action => "lancar_impostos_na_parcela"
    end
  end

  def atualiza_juros
    @parcela = @conta.parcelas.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    render :update do |page|
      @parcela.calcular_juros_e_multas!(params[:data])
      page[:parcela_valor_da_multa_em_reais].value = (@parcela.valor_da_multa.real.to_f / 100).real.to_s
      page[:parcela_valor_dos_juros_em_reais].value = (@parcela.valor_dos_juros.real.to_f / 100).real.to_s
      #page[:parcela_valor_da_multa_em_reais].value = format("%.2f", (@parcela.valor_da_multa / 100.0)).to_s
      #page[:parcela_valor_dos_juros_em_reais].value = format("%.2f", (@parcela.valor_dos_juros / 100.0)).to_s
      page.call :insere_nome_e_id_para_baixa_na_atualizacao_de_juros
      page.call :valor_total
    end
  end

  def baixa
    @parcela = @conta.parcelas.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    #    flash[:notice] = "Por favor, entre em contato com o Diretório Regional antes de realizar a baixa." if @parcela.situacao == Parcela::ENVIADO_AO_DR
    @parcela.calcular_juros_e_multas!
    unless @parcela.baixada
      @parcela.cheques.build
      @parcela.cartoes.build
    end
    @parcela.data_da_baixa = Date.today if !@parcela.data_da_baixa_was
    @parcela.historico = @conta.historico  if !@parcela.historico_was
    @parcela.data_do_pagamento = Date.today if !@parcela.data_do_pagamento_was
  end

  def gravar_baixa
    @parcela = @conta.parcelas.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    if params[:parcela][:baixa_pela_dr] == "1"
      conf_senha = @parcela.unidade.verifica_senha_dr(params[:senha_dr])
      if conf_senha
        retorno = @parcela.baixar_parcela(session[:ano], current_usuario, params[:parcela])
        if retorno.first == true
          flash[:notice] = retorno.last
          redirect_to url_for(:controller => 'parcelas', :action => 'baixa', :id => params[:id])
        else
          flash.now[:notice] = retorno.last
          render :action => "baixa"
        end
      else
        @parcela.attributes = params[:parcela]

        #        @parcela.valor_da_multa = format("%.2f", params[:parcela][:valor_da_multa_em_reais]).to_f * 100
        #        @parcela.taxa_boleto = format("%.2f", params[:parcela][:taxa_boleto_em_reais]).to_f * 100
        #        @parcela.protesto = format("%.2f", params[:parcela][:protesto_em_reais]).to_f * 100
        #        @parcela.honorarios = format("%.2f",  params[:parcela][:honorarios_em_reais]).to_f * 100
        #        @parcela.valor_do_desconto = format("%.2f", params[:parcela][:valor_do_desconto_em_reais]).to_f * 100
        #        @parcela.outros_acrescimos = format("%.2f", params[:parcela][:outros_acrescimos_em_reais]).to_f * 100
        #        @parcela.valor_dos_juros = format("%.2f", params[:parcela][:valor_dos_juros_em_reais]).to_f * 100

        @parcela.valor_da_multa = params[:parcela][:valor_da_multa_em_reais].real.to_f * 100
        @parcela.valor_da_multa = params[:parcela][:valor_da_multa_em_reais].real.to_f * 100
        @parcela.taxa_boleto = params[:parcela][:taxa_boleto_em_reais].real.to_f * 100
        @parcela.protesto = params[:parcela][:protesto_em_reais].real.to_f * 100
        @parcela.honorarios =  params[:parcela][:honorarios_em_reais].real.to_f * 100
        @parcela.valor_do_desconto = params[:parcela][:valor_do_desconto_em_reais].real.to_f * 100
        @parcela.outros_acrescimos = params[:parcela][:outros_acrescimos_em_reais].real.to_f * 100
        @parcela.valor_dos_juros = params[:parcela][:valor_dos_juros_em_reais].real.to_f * 100

        @parcela.cheques.build
        @parcela.cartoes.build

        flash.now[:notice] = 'A senha digitada não está correta, verifique!'
        render :action => "baixa"
      end
    else
      retorno = @parcela.baixar_parcela(session[:ano], current_usuario, params[:parcela])
      if retorno.first == true
        flash[:notice] = retorno.last
        redirect_to url_for(:controller => 'parcelas', :action => 'baixa', :id => params[:id])
      else
        flash.now[:notice] = retorno.last
        render :action => "baixa"
      end
    end
  end

  def estornar_parcela_baixada
    @parcela = @conta.parcelas.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    retorno = @parcela.estorna_parcela(current_usuario, params[:justificativa], params[:data_estorno])
    render :update do |page|
      if retorno.first
        page.alert retorno.last
        page << 'Modalbox.hide()'
        page << 'window.location.reload()'
      else
        page.alert "Não foi possível realizar o estorno da parcela!\n* #{retorno.last}"
      end
    end
  end

  def listar_recibos
    @parcelas = @conta.parcelas.que_estao_baixadas.sort_by {|a| a.numero.nil? ? a.numero_parcela_filha.real.to_f : a.numero.real.to_f}
    if @parcelas.empty?
      flash[:notice] = 'Não existem parcelas baixadas para impressão de recibo.'
      redireciona_para_conta
    end
  end
  
  def imprimir_recibos
    @unidade = Unidade.find(session[:unidade_id])
    @pessoa = RecebimentoDeConta.find(params[:recebimento_de_conta_id]).pessoa
    @data = params[:data]
    if params[:recibo_impresso]
      @parcelas = Parcela.find(params[:recibo_impresso]).sort_by {|a| a.numero.nil? ? a.numero_parcela_filha.real.to_f : a.numero.real.to_f}
      respond_to {|format| format.pdf{render :layout => 'recibo'}}
    else
      flash[:notice] = 'Não foram encontrados registros com estes parâmetros.'
      redirect_to(listar_recibos_recebimento_de_conta_parcelas_path(@conta.id))
    end
  end

  def cancelar
    @parcela = Parcela.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    render :update do |page|
      retorno = @parcela.cancelar(current_usuario, params[:justificativa] ||= '')
			if retorno.first
        page.alert retorno.last
        page.reload
      else
        page.alert retorno.last
      end
    end
  end

  def baixa_dr
    @parcela = @conta.parcelas.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    retorno = @parcela.unidade.verifica_senha_dr(params[:senha])
    if retorno
      @parcela.baixando_dr(current_usuario)
      flash[:notice] = 'Baixa DR efetuada com sucesso!'
      redireciona_para_conta
    else
      flash.now[:notice] = 'A senha digitada não está correta, verifique!'
      render :action => 'baixa'
    end
  end

  def baixa_parcial
    @parcela = Parcela.find(params[:parcela_id])
    @parcela.ano_contabil_atual = session[:ano]
    render :update do |page|
      retorno = @parcela.baixar_parcialmente(session[:ano], current_usuario, params)
      if retorno.first
        page.alert retorno.last
        page << 'window.location.reload()'
      else
        page.alert retorno.last
      end
    end
  end

  def baixa_parcial_pagamentos
    @parcela = Parcela.find(params[:parcela_id])
    @parcela.ano_contabil_atual = session[:ano]
    render :update do |page|
      retorno = @parcela.baixar_parcialmente_contas_a_pagar(session[:ano], current_usuario, params)
      if retorno.first
        page.alert retorno.last
        page << 'window.location.reload()'
      else
        page.alert retorno.last
      end
    end
  end
  
  def baixa_parcial_dr
    @parcela = Parcela.find(params[:parcela_id])
    @parcela.ano_contabil_atual = session[:ano]
    render :update do |page|
      retorno = @parcela.baixar_parcialmente_dr(session[:ano], current_usuario, params)
      if retorno.first
        page.alert retorno.last
        page << 'window.location.reload()'
      else
        page.alert retorno.last
      end
    end
  end
  
  def carrega_geracao_boleto
    @parcela = Parcela.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    render :update do |page|
      page.show 'form_para_geracao_boleto'
      page.replace_html('form_para_geracao_boleto', :partial => 'form_geracao_boleto')
      page.visual_effect :highlight, 'form_para_geracao_boleto'
    end
  end

  def gerar_boleto
    Dir.mkdir(RAILS_ROOT + '/tmp/boletos/') unless File.exist?("#{RAILS_ROOT}/tmp/boletos")
    @parcela = Parcela.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    boleto = @parcela.to_boleto(params["convenio_id"])
    if boleto.nil?
      flash[:notice] = 'Selecione uma conta corrente válida'
      redireciona_para_conta
    else
      #send_data(boleto.to(params[:formato]), :filename => "boleto_#{boleto.codigo_barras}.#{params[:formato]}")
      #send_data(boleto.to('pdf'), :filename => "boleto_#{boleto.codigo_barras}.pdf")
      boleto.to(boleto.codigo_barras, 'pdf')
      send_file(RAILS_ROOT + "/tmp/boletos/#{boleto.codigo_barras}.pdf", :type => 'application/pdf')
    end
  end

  def realizar_estorno_provisao_de_pagamento
    @pagamento_de_conta = PagamentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    @parcela.ano_contabil_atual = session[:ano]
    @pagamento_de_conta.usuario_corrente = current_usuario
    render :update do |page|
      retorno = @pagamento_de_conta.estornar_provisao_pagamento(params, @parcela.id, @pagamento_de_conta.usuario_corrente.id)
      page.alert retorno.last
      if retorno.first == true
        page << 'Modalbox.hide()'
        page << 'window.location.reload()'
      end
    end
  end

  def efetuar_resgate
    @parcela = Parcela.find(params[:id])
    @parcela.ano_contabil_atual = session[:ano]
    @recebimento_de_conta = @parcela.conta
    @recebimento_de_conta.usuario_corrente = current_usuario
    render :update do |page|
      retorno = @parcela.efetuar_troca_de_pagamento(params, @recebimento_de_conta.usuario_corrente, session[:ano])
      page.alert retorno.last
      if retorno.first == true
        page << 'Modalbox.hide()'
        page << 'window.location.reload()'
      end
    end
  end

  def cancelar_para_ctr_canc
    @parcela = Parcela.find(params[:id])
    @recebimento_de_conta = @parcela.conta
    @recebimento_de_conta.usuario_corrente = current_usuario
    render :update do |page|
      retorno = @parcela.cancelar_parcela_contrato_cancelado(params, @recebimento_de_conta.usuario_corrente, session[:ano])
      page.alert retorno.last
      if retorno.first == true
        page << 'Modalbox.hide()'
        page << 'window.location.reload()'
      end
    end
  end

  private

  def redireciona_para_conta
    if params.has_key?(:pagamento_de_conta_id)
      redirect_to pagamento_de_conta_path(@conta.id)
    else
      redirect_to recebimento_de_conta_path(@conta.id)
    end
  end

  def carrega_entidade
    @entidade  = Unidade.find_by_id(session[:unidade_id]).entidade
  end

  def verifica_se_pode_acessar_rateio
    @parcela = Parcela.find params[:id]
    if @parcela.conta.rateio == 0
      flash[:notice] = 'Esta conta não possui rateio.'
      redirect_to login_path
    end
  end
  
  def verifica_se_parcela_esta_cancelada
    @parcela = Parcela.find params[:id]
    if @parcela.situacao == Parcela::CANCELADA
      flash.now[:notice] = 'Esta parcela está cancelada.'
      redirect_to login_path
    end
  end

  def verifica_se_parcela_esta_renegociada
    @parcela = Parcela.find params[:id]
    redirect_to recebimento_de_conta_path(@parcela.conta.id) if @parcela.situacao == Parcela::RENEGOCIADA
  end

  def verificando_situacao_contrato
    @parcela = Parcela.find(params[:id])
    if @parcela.conta_type == 'RecebimentoDeConta'
      verifica_se_contrato_esta_cancelado(params[:recebimento_de_conta_id])
    end
  end

  def nao_pode_alterar_parcelas_de_um_contrato_com_situacao_fiemt_inativo
    if params.has_key?(:recebimento_de_conta_id)
      @recebimento_de_conta = RecebimentoDeConta.find params[:recebimento_de_conta_id]
      if @recebimento_de_conta.situacao_fiemt == RecebimentoDeConta::Inativo &&
          @recebimento_de_conta.situacao == RecebimentoDeConta::Cancelado
        flash[:notice] = "Não é possível alterar dados de um contrato inativo."
        redirect_to recebimento_de_conta_path(params[:recebimento_de_conta_id])
      end
    end
  end

end
