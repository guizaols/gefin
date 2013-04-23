class DependentesController < ApplicationController

  before_filter :carrega_pessoa

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDasPessoas,
    'any' => Perfil::Pessoas
  }
    
  def show
    @dependente = Dependente.find_by_id_and_pessoa_id(params[:id],params[:pessoa_id])
  end

  def new
    @dependente = Dependente.new
  end

  def edit
    @dependente = Dependente.find_by_id_and_pessoa_id(params[:id],params[:pessoa_id])
  end

  def create
    @dependente = Dependente.new(params[:dependente])
    @dependente.pessoa_id = params[:pessoa_id]
    if @dependente.save
      flash[:notice] = @pessoa.caption_dependente_beneficiario + ' criado com sucesso!'
      redirect_to  pessoa_path(@dependente.pessoa_id)
    else
      render :action => "new"
    end
  end

  def update
    @dependente = Dependente.find_by_id_and_pessoa_id(params[:id],params[:pessoa_id])
    if @dependente.update_attributes(params[:dependente])
      flash[:notice] = @pessoa.caption_dependente_beneficiario + ' atualizado com sucesso!'
      redirect_to pessoa_path(@dependente.pessoa_id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @dependente = Dependente.find_by_id_and_pessoa_id(params[:id],params[:pessoa_id])
    @dependente.destroy
    flash[:notice] = @pessoa.caption_dependente_beneficiario + ' excluído com sucesso!'
    redirect_to pessoa_path(@dependente.pessoa_id)
  end
  
  private
 
  def carrega_pessoa
    @pessoa = Pessoa.find params[:pessoa_id]
  end
 
 
  
end
