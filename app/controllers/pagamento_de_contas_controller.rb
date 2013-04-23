class PagamentoDeContasController < ApplicationController

  before_filter :so_pode_alterar_contas_desta_unidade
  
  PERMISSOES = {
    CUD => Perfil::ManipularDadosDePagamentoDeContas,
    'any' => Perfil::PagamentoDeContas,
    ['gerar_parcelas','destroy'] => Perfil::ManipularDadosDePagamentoDeContas,
    ['libera_pagamento_de_conta_fora_do_prazo'] => Perfil::LiberarContratoPeloDrPagamentoDeConta
  }

  def index
    params[:busca] ||= {}
    @pagamento_de_contas = PagamentoDeConta.pesquisa_simples(session[:unidade_id], params[:busca], params[:page])
  end

  def show
    @pagamento_de_conta = PagamentoDeConta.find(params[:id])
  end

  def gerar_parcelas
    @pagamento_de_conta = PagamentoDeConta.find(params[:id])
    @pagamento_de_conta.usuario_corrente = current_usuario
    retorno = @pagamento_de_conta.gerar_parcelas(session[:ano])
    flash[:notice] = retorno.last
    redirect_to pagamento_de_conta_path(@pagamento_de_conta.id)
  end

  def new
    @pagamento_de_conta = PagamentoDeConta.new :ano => session[:ano], :unidade_id => session[:unidade_id]
    @pagamento_de_conta.unidade_organizacional_id = Unidade.find_by_id(session[:unidade_id]).unidade_organizacional.id rescue nil
  end

  def edit
    @pagamento_de_conta = PagamentoDeConta.find(params[:id])
  end

  def create
    @pagamento_de_conta = PagamentoDeConta.new(params[:pagamento_de_conta])
    @pagamento_de_conta.unidade_id = session[:unidade_id]
    @pagamento_de_conta.ano = session[:ano]
    @pagamento_de_conta.usuario_corrente = current_usuario
    entidade = Unidade.find_by_id(session[:unidade_id]).entidade
		if @pagamento_de_conta.save
      #@pagamento_de_conta.gerar_parcelas(session[:ano])
       retorno_parcelas = false
       while !retorno_parcelas
        retorno_parcelas = @pagamento_de_conta.gerar_parcelas(session[:ano]).first
       end
      retorno = @pagamento_de_conta.verifica_contratos(entidade.id, params[:pagamento_de_conta][:primeiro_vencimento], params[:pagamento_de_conta][:pessoa_id])
      unless retorno.blank?
        flash[:notices] = retorno
      end
      flash[:notice] = 'Conta a pagar criada com sucesso!'
      redirect_to pagamento_de_conta_path(@pagamento_de_conta.id)
    else
      @pagamento_de_conta.unidade_organizacional_id = Unidade.find_by_id(session[:unidade_id]).unidade_organizacional.id rescue nil
      render :action => "new"
    end
  end

  def update
    @pagamento_de_conta = PagamentoDeConta.find(params[:id])
    pagamento_original = PagamentoDeConta.find(params[:id])
    @pagamento_de_conta.unidade_id = session[:unidade_id]
    @pagamento_de_conta.ano = session[:ano]
    @pagamento_de_conta.ano_contabil_atual = session[:ano]
    @pagamento_de_conta.usuario_corrente = current_usuario
    entidade = Unidade.find_by_id(session[:unidade_id]).entidade
    if @pagamento_de_conta.update_attributes(params[:pagamento_de_conta])
      @pagamento_de_conta.criar_follow_up_update(pagamento_original, current_usuario)
      retorno = @pagamento_de_conta.verifica_contratos(entidade.id, @pagamento_de_conta.primeiro_vencimento, params[:pagamento_de_conta][:pessoa_id])
      unless retorno.blank?
        flash[:notices] = retorno
      end
      flash[:notice] = 'Conta a pagar atualizada com sucesso!'
      redirect_to pagamento_de_conta_path(@pagamento_de_conta.id)
    else
      render :action => "edit"
    end
  end

    def destroy
      @pagamento_de_conta = PagamentoDeConta.find(params[:id])
     if @pagamento_de_conta.excluir_contrato
         flash[:notice] = 'Conta a pagar excluída com sucesso!'
        redirect_to(pagamento_de_contas_url)
      else
        flash[:notice] = 'Não foi possível excluir este contrato!'
        redirect_to(pagamento_de_contas_url)
      end
    end

  def resumo
    @pagamento_de_conta = PagamentoDeConta.find params[:id]
    respond_to do |format|
      format.js do
        render :update do |page|
          page.new_window_to :url => resumo_pagamento_de_conta_path, :id => params[:id], :format => 'pdf'
        end
      end
      format.pdf {@titulo = 'RESUMO DE CONTA A PAGAR'}
    end
  end

  # RF4
  def carrega_parcelas
    @pagamento_de_conta = PagamentoDeConta.find(params[:id])
  end

  # RF4
  def atualiza_valores_das_parcelas
    @pagamento_de_conta = PagamentoDeConta.find(params[:id])
    resultado_operacao = @pagamento_de_conta.atualizar_valor_das_parcelas(session[:ano], params[:parcela], current_usuario)
    if resultado_operacao == true
      flash[:notice] = "Dados alterados com sucesso!"
      redirect_to pagamento_de_conta_path(@pagamento_de_conta.id)
    else
      flash.now[:notice] = resultado_operacao if resultado_operacao.is_a?String
      render :action => "carrega_parcelas"
    end
  end

  # RF12
  def libera_pagamento_de_conta_fora_do_prazo
    @conta = PagamentoDeConta.find(params[:id])
    @conta.liberacao_dr_faixa_de_dias_permitido = true
    if @conta.save
      HistoricoOperacao.cria_follow_up("Conta liberada para recebimento fora do prazo pelo DR.", current_usuario, @conta)
      flash[:notice] = "Conta liberada pelo DR."
    else
      flash[:notice] = "Não foi possível liberar a conta."
    end
    redirect_to pagamento_de_contas_path
  end

  def estorna_provisao_de_pagamento
    @conta = PagamentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    render :update do |page|
      page << "Modalbox.show($('form_para_estornar_provisao_de_pagamento'), {title: 'Estorno de Provisão', width:550, afterLoad: function(){#{page.replace_html 'form_para_estornar_provisao_de_pagamento', :partial => 'estorno_pagamento'}} });"
    end
  end

  def carrega_baixa_parcial
    @conta = PagamentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    render :update do |page|
      page.show 'form_para_baixa_parcial_pagamentos'
      page.replace_html('form_para_baixa_parcial_pagamentos', :partial => 'form_baixa_parcial', :locals => {:parcela => @parcela})
      page.visual_effect :highlight, 'form_para_baixa_parcial_pagamentos'
    end
  end
  
  private

  def so_pode_alterar_contas_desta_unidade

    if params[:id]
      @pagamento_de_conta = PagamentoDeConta.find params[:id]
      unless @pagamento_de_conta.unidade_id == session[:unidade_id].to_i
        flash[:notice] = 'Essa Conta a Pagar pertence a outra unidade.'
        redirect_to login_path
      end
    end
  end

end
