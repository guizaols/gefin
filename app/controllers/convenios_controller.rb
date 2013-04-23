class ConveniosController < ApplicationController
  
  PERMISSOES = {
    CUD => Perfil::ManipularDadosDosConvenios,
    'any' => Perfil::Convenios
  }

  def index
    @convenios = Convenio.find_all_by_unidade_id(session[:unidade_id])
  end

  def show
    @convenio = Convenio.find(params[:id])
  end

  def new
    @convenio = Convenio.new
  end

  def edit
    @convenio = Convenio.find(params[:id])
  end

  def create
    @convenio = Convenio.new(params[:convenio])
    @convenio.unidade_id = session[:unidade_id]
    if @convenio.save
      flash[:notice] = 'Convênio criado com Sucesso.'
      redirect_to(@convenio)
    else
      render :action => "new"
    end
  end

  def update
    @convenio = Convenio.find(params[:id])
    if @convenio.update_attributes(params[:convenio])
      flash[:notice] = 'Convênio Alterado com Sucesso.'
      redirect_to(@convenio)
    else
      render :action => "edit"
    end
  end

  
  def destroy
    @convenio = Convenio.find(params[:id])
    @convenio.destroy
    redirect_to(convenios_url)
  end

  
end
