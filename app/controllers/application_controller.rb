class ApplicationController < ActionController::Base
  
  PERMISSOES = {}
  NAO_PASSA_POR_PERMISSAO = []
  CRUD = ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy']
  CUD = ['new', 'create', 'edit', 'update', 'destroy']

  #session_times_out_in 10.seconds, :after_timeout => :do_something
  helper :all
  include AuthenticatedSystem
  include ExceptionNotifiable

  filter_parameter_logging :password
  before_filter :login_required
  before_filter :session_expiry, :except => [:login_required, :logout,:update_activity_time]
  before_filter :update_activity_time, :except => [:login_required, :logout]
  before_filter :login_ativo
  before_filter :verica_se_usuario_tem_permissao, :except => NAO_PASSA_POR_PERMISSAO

  def session_expiry
    if session[:expires_at] != nil
      @time_left = (session[:expires_at] - Time.now).to_i rescue 10
      unless @time_left > 0
        session[:expires_at] = nil
        flash.now[:notice] = 'Sua sessão expirou. Favor entrar novamente.'
        redirect_to :controller => 'sessao', :action => 'destroy'
      end
    else
      :update_activity_time
    end
  end

  def update_activity_time
    #session[:expires_at] = 20.minutes.from_now
    #session[:expires_at] = 60.minutes.from_now
    unidade = Unidade.find session[:unidade_id] rescue 20
    session[:expires_at] = unidade.tempo_sessao.minutes.from_now rescue 20
  end
  
  def sigla_da_unidade_da_sessao
    Unidade.find session[:unidade_id]
  end

  helper_method :sigla_da_unidade_da_sessao

#	def do_something
#    flash[:notice] = 'FUUUUUU' # hahaha
#    redirect_to new_sessao_path
#	end

  def login_ativo
    if current_usuario && current_usuario.status == Usuario::INATIVO
      logout_killing_session!
      flash[:notice] = 'Seu usuário foi inativado!'
      redirect_to new_sessao_path
    end
  end

  def bloquear_acesso
    logger.warn("GEFIN: Permissão Negada para #{current_usuario.inspect}: #{params.inspect}!")
    redirect_to login_path
    flash[:notice] = 'Você não tem permissão para acessar este módulo!'
  end
 
  def verica_se_usuario_tem_permissao
    permissoes_para_validar = self.class::PERMISSOES.select{|k, v| k == 'any' || k.to_a.include?(params[:action]) }.collect(&:last).flatten.compact
    bloquear_acesso unless permissoes_para_validar.all? {|acao| current_usuario.possui_permissao_para acao}
  end

  def verifica_se_contrato_esta_cancelado(id)
    @recebimento_de_conta = RecebimentoDeConta.find(id)
    if @recebimento_de_conta.situacao == RecebimentoDeConta::Cancelado
      flash[:notice] = 'Este contrato está cancelado.'
      redirect_to login_path
    end
  end

  def carrega_conta
    if params.has_key?(:pagamento_de_conta_id)
      @conta = PagamentoDeConta.find params[:pagamento_de_conta_id]
    else
      @conta = RecebimentoDeConta.find params[:recebimento_de_conta_id]
    end
  end

  def rescue_action_in_public(exception)
    case exception
    when *self.class.exceptions_to_treat_as_404
      render_404

      deliverer = self.class.exception_data
      data = case deliverer
      when nil then {}
      when Symbol then send(deliverer)
      when Proc then deliverer.call(self)
      end
      Thread.new do
        ExceptionNotifier.deliver_exception_notification(exception, self,
          request, data)
      end
      
    else
      render_500

      deliverer = self.class.exception_data
      data = case deliverer
      when nil then {}
      when Symbol then send(deliverer)
      when Proc then deliverer.call(self)
      end

      Thread.new do
        ExceptionNotifier.deliver_exception_notification(exception, self,
          request, data)
      end
    end
  end

  def carregar_unidade
    @unidade = Unidade.find session[:unidade_id]
  end

end