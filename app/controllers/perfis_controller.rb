class PerfisController < ApplicationController

  PERMISSOES = {
    CUD => Perfil::ManipularPerfisDeAcesso,
    'any' => Perfil::PerfisDeAcesso
  }

  def index
    @perfis = Perfil.all :order => 'descricao'
  end

  def show
    @perfil = Perfil.find params[:id]
    @permissoes = Perfil.lista_de_permissoes_para_view
  end

  def edit
    @perfil = Perfil.find params[:id]
    @permissoes = Perfil.lista_de_permissoes_para_view
  end

  def new
    @perfis = Perfil.all
    @perfil = Perfil.new
    @permissoes = Perfil.lista_de_permissoes_para_view
    @selecionado = ''
  end

  def update
    @perfil = Perfil.find params[:id]
    permissoes = ''
    if params[:perfil][:descricao].blank?
      flash[:notice] = "Preencha o campo descrição."
      redirect_to edit_perfil_path(@perfil)
    else
      @perfil.permissao.size.times do |idx|
        permissoes += (params[:permissao][idx.to_s].nil? ? 'N' : 'S')
      end
      params[:perfil][:permissao] = permissoes
      if @perfil.update_attributes(params[:perfil])
        flash[:notice] = 'Perfil atualizado com sucesso!'
        redirect_to perfil_path(@perfil)
      else
        render :edit
      end
    end
  end

  def update_formulario
    @perfis = Perfil.all
    @perfil = (params[:descricao]!='') ? Perfil.new(:permissao => Perfil.find_by_descricao(params[:descricao]).permissao) : Perfil.new
    @perfil.descricao = params[:nome]
    @permissoes = Perfil.lista_de_permissoes_para_view
    @selecionado = params[:descricao]
    render :update do |page|
      page.replace_html('formulario',:partial => "form")
    end
  end

  def create
    permissoes = ''
    if params[:perfil][:descricao].blank?
      flash[:notice] = "Preencha o campo descrição."
      redirect_to new_perfil_path
    else
      Perfil.first.permissao.size.times do |idx|
        permissoes += (params[:permissao][idx.to_s].nil? ? 'N' : 'S')
      end
      params[:perfil][:permissao] = permissoes
      @perfil = Perfil.new params[:perfil]
      flash[:notice] = 'O campo descrição deve ser preenchido'
      if @perfil.save
        redirect_to perfis_path
        flash[:notice] = "Perfil cadastrado com sucesso!"
      else
        render :new
      end
    end
  end

  def destroy
    @perfil = Perfil.find params[:id]
    redirect_to perfis_path
    unless @perfil.destroy
      flash[:notice] = @perfil.errors.full_messages.first
    end
  end

end
