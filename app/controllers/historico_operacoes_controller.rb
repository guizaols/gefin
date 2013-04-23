class HistoricoOperacoesController < ApplicationController

  before_filter :so_pode_alterar_historico_operacoes_desta_unidade
  before_filter :nao_pode_alterar_parcelas_de_um_contrato_com_situacao_fiemt_inativo, :except => [:index]
  before_filter :verifica_permissao

  PERMISSOES = {
    'index' => @permissao
  }

  def index
    @historico_operacoes = @conta.historico_operacoes
    @historico_operacao = HistoricoOperacao.new
    respond_to do |format|
      format.html
      format.print do
        @titulo = "FOLLOW-UP"
        #render :layout => 'relatorio_horizontal'
      end
    end
  end

  def create
    @historico_operacao = HistoricoOperacao.new params[:historico_operacao]
    if(@conta.is_a?(Movimento))
      @historico_operacao.movimento = @conta
    else
      @historico_operacao.conta = @conta
    end
    @historico_operacao.usuario = current_usuario
    if @historico_operacao.save
      flash[:notice] = 'Follow-Up criado com sucesso!'
      redireciona_para_conta
    else
      @historico_operacoes = @conta.historico_operacoes
      render :action => 'index'
    end
  end

  private

  def carrega_conta
    if params.has_key?(:pagamento_de_conta_id)
      @conta = PagamentoDeConta.find params[:pagamento_de_conta_id]
    elsif params.has_key?(:recebimento_de_conta_id)
      @conta = RecebimentoDeConta.find params[:recebimento_de_conta_id]
    else
      @conta = Movimento.find params[:movimento_id]
    end
  end

  def verifica_permissao
    if params.has_key?(:pagamento_de_conta_id)
      @permissao = Perfil::ConsultarFollowUpAPagar
    else
      @permissao = Perfil::ConsultarFollowUpAReceber
    end
    unless current_usuario.possui_permissao_para_um_item(@permissao)
      flash[:notice] = 'Você não tem permissão para acessar este módulo!'
      redirect_to login_path
    end
  end

  def redireciona_para_conta
    if params.has_key?(:pagamento_de_conta_id)
      redirect_to pagamento_de_conta_historico_operacoes_path(@historico_operacao.conta_id)
    elsif params.has_key?(:recebimento_de_conta_id)
      redirect_to recebimento_de_conta_historico_operacoes_path(@historico_operacao.conta_id)
    else
      redirect_to movimento_historico_operacoes_path(@historico_operacao.movimento_id)
    end
  end

  def so_pode_alterar_historico_operacoes_desta_unidade
    carrega_conta
    unless @conta.unidade_id == session[:unidade_id].to_i
      flash[:notice] = 'Esse Follow-Up pertence a outra unidade.'
      redirect_to("/login")
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
