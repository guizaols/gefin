class UsuariosController < ApplicationController
  
  PERMISSOES = {
    CUD => Perfil::ManipularDadosDosUsuarios,
    ['index', 'show'] => Perfil::Usuarios
  }
  
  before_filter :so_pode_alterar_usuarios_desta_unidade

  def index 
    @usuarios = Usuario.find_all_by_unidade_id(session[:unidade_id], :include => :funcionario, :order => 'pessoas.nome ASC')
  end

  def show
  end

  def new
    @usuario = Usuario.new params[:usuario]
  end

  def create
    @usuario = Usuario.new params[:usuario]
    retorno = @usuario.apenas_um_usuario_ativo(session[:unidade_id])
    if !retorno.first
      @usuario.unidade_id = session[:unidade_id]
      @usuario.status = Usuario::ATIVO
      success = @usuario && @usuario.save
      if success && @usuario.errors.empty?
        redirect_back_or_default usuarios_path
        flash[:notice] = retorno.last
      else
        flash[:error]  = "Por favor, preencha todos os dados corretamente e tente novamente!"
        render :action => 'new'
      end
    else
      flash[:notice] = retorno.last
      redirect_to usuarios_path
    end
  end

  def edit
  end

  def update
    retorno = @usuario.apenas_um_usuario_ativo(session[:unidade_id])
    if !retorno.first
      if @usuario.update_attributes params[:usuario]
        flash[:notice] = "Usuario alterado com sucesso!"
        redirect_to usuarios_path
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = retorno.last
      redirect_to usuarios_path
    end
  end

  def destroy
    if @usuario.destroy
      flash[:notice] = 'Usuário excluído com sucesso!'
    else
      flash[:notice] = @usuario.mensagem_de_erro
    end
    redirect_to usuarios_path
  end

  def carrega_form_alterar_senha
    if current_usuario.id == params[:id].to_i
      @usuario = Usuario.find(params[:id])
    else
      flash[:notice] = "Você está tentando alterar a senha de outro usuário!"
      redirect_back_or_default main_path
    end
  end

  def alterar_senha
    if current_usuario.id == params[:id].to_i
      if current_usuario.authenticated?(params[:usuario][:antiga_senha])
        current_usuario.password = params[:usuario][:password]
        current_usuario.password_confirmation = params[:usuario][:password_confirmation]
        if current_usuario.save
          flash[:notice] = "Senha alterada com sucesso!"
        else
          flash[:notice] = "O campo senha e confirmação de senha devem ser iguais e não nulos!"
          render :action => 'carrega_form_alterar_senha'
          return
        end
      else
        flash[:notice] = 'O campo senha atual está incorreto!'
        render :action => 'carrega_form_alterar_senha'
        return
      end
    else
      flash[:notice] = "Não foi possível alterar!"
    end
    redirect_to(pessoa_path(current_usuario.funcionario))
  end

  def ativa_inativa_usuarios
    @usuario = Usuario.find(params[:id])
    retorno = @usuario.ativar_inativar_usuario(params[:ativo_inativo], session[:unidade_id])
    render :update do |page|
      page.alert retorno.last
      page.reload if retorno.first
    end
  end

  private
 
  def so_pode_alterar_usuarios_desta_unidade
    if params[:id]
      @usuario = Usuario.find params[:id]
      unless @usuario.unidade_id == session[:unidade_id]
        flash[:notice] = 'Esse usuário pertence a outra unidade.'
        redirect_to login_path
      end
    end
  end

end
