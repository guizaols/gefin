class ImpostosController < ApplicationController

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDosImpostos,
    'any' => Perfil::Impostos
  }  
   
  before_filter :carrega_entidade,:so_pode_alterar_impostos_desta_entidade
  
  def index
    @impostos = Imposto.find_all_by_entidade_id(@entidade.id, :order => 'descricao ASC')
  end

  def show
  end

  def new
    @imposto = Imposto.new
  end

  def edit
    @imposto.aliquota = @imposto.aliquota.real.to_s
  end

  def create
    @imposto = Imposto.new(params[:imposto])
    @imposto.entidade = Unidade.find_by_id(session[:unidade_id]).entidade

    if @imposto.save
      flash[:notice] = 'Imposto criado com sucesso!'
      redirect_to impostos_path
    else
      @imposto.aliquota = @imposto.aliquota.real.to_s
      render :action => "new"
    end
  end

  def update
    @imposto = Imposto.find(params[:id])

    if @imposto.update_attributes(params[:imposto])
      flash[:notice] = 'Imposto atualizado com sucesso!'
      redirect_to impostos_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @imposto = Imposto.find(params[:id])
    @imposto.destroy
    flash[:notice] = 'Imposto excluído com sucesso!'
    redirect_to(impostos_url)
  end
  
  private

  def carrega_entidade
    @entidade = Unidade.find_by_id(session[:unidade_id]).entidade
  end  
  
  def so_pode_alterar_impostos_desta_entidade
    if params[:id]
      @imposto = Imposto.find params[:id]
      unless @imposto.entidade == @entidade
        flash[:notice] = 'Esse imposto pertence a outra entidade.'
        redirect_to(login_path)
      end
    end
  end
end
