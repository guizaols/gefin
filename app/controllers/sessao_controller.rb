class SessaoController < ApplicationController
  
  skip_before_filter :login_required, :except => [:altera_ano, :altera_unidade, :destroy]
  skip_before_filter :session_expiry, :only => [:new,:create,:destroy]
  skip_before_filter :update_activity_time, :only =>[:new,:create,:destroy]

  PERMISSOES = {
    'altera_ano' => Perfil::AlterarAno,
    'altera_unidade' => Perfil::AlterarUnidade
  }

  def new
  end

  def create
    logout_keeping_session!
    usuario = Usuario.authenticate(params[:login], params[:password])
    if usuario && usuario.status == Usuario::ATIVO
      self.current_usuario = usuario
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      session[:ano] = DateTime.now.strftime("%Y").to_i
      session[:unidade_id] = usuario.unidade_id.to_i
      :update_activity_time
      redirect_back_or_default main_path
      flash[:notice] = "Usuário autenticado com sucesso!"
    elsif usuario && usuario.status == Usuario::INATIVO
      flash[:notice] = 'Este usuário está inativo'
      note_failed_signin
      @login = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    else
      flash[:notice] = 'Dados incorretos! Verifique os dados e tente novamente, por favor.'
      note_failed_signin
      @login = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "Logout efetuado com sucesso!"
    redirect_back_or_default new_sessao_path
  end

  def altera_ano
    render :update do |page|
      if params.has_key?(:ano) && !params[:ano].blank? && params[:ano].match(%r{^([0-9]{4})$})
        if current_usuario.possui_permissao_para(Perfil::AlterarAno)
          session[:ano] = params[:ano].to_i
          page.alert 'Ano alterado com sucesso!'
          page << 'Modalbox.hide()'
          page << 'window.location.reload()'
        else
          page.alert 'Você não tem permissão para acessar este módulo!'
          page.redirect_to login_path
        end
      else
        page.alert 'Dados incorretos!'
      end
    end
  end

  def altera_unidade
    render :update do |page|
      if params.has_key?(:unidade_id) && !params[:unidade_id].blank? && !Unidade.find_by_id(params[:unidade_id]).blank?
        if current_usuario.possui_permissao_para(Perfil::AlterarUnidade)
          session[:unidade_id] = params[:unidade_id].to_i
          page.alert 'Unidade alterada com sucesso!'
          page << 'Modalbox.hide()'
          page.redirect_to main_path
        else
          page.alert 'Você não tem permissão para acessar este módulo!'
          page.redirect_to login_path
        end
      else
        page.alert 'Dados incorretos!'
      end
    end
  end

#  def active
#    render_session_status
#  end
#    
#  def timeout
#    render_session_timeout
#  end
  
  protected
  
  def note_failed_signin
    flash[:error] = "Não posso fazer login como '#{params[:login]}'"
    logger.warn "Login falhou para '#{params[:login]}' de #{request.remote_ip} ás #{Time.now.utc}"
  end

end
