class ParametroContaValoresController < ApplicationController

  PERMISSOES = {
     CUD => Perfil::ManipularDadosDeParametroContaValores,
    'any' => Perfil::ParametroContaValor
  }
    
  before_filter :so_pode_alterar_parametros_desta_unidade
  
  def index
    @parametro_conta_valores = ParametroContaValor.find_all_by_unidade_id_and_ano(session[:unidade_id], session[:ano], :include => :conta_contabil, :order => 'plano_de_contas.codigo_contabil ASC')
  end
  
  def new
    @parametro_conta_valor = ParametroContaValor.new
  end

  def edit
  end

  def create
    @parametro_conta_valor = ParametroContaValor.new(params[:parametro_conta_valor])
    @parametro_conta_valor.unidade_id = session[:unidade_id]
    @parametro_conta_valor.ano = session[:ano]
    if @parametro_conta_valor.save
      flash[:notice] = 'Parâmetro criado com sucesso!'
      redirect_to parametro_conta_valores_path
    else
      render :action => "new"
    end
  end

  def update
    if @parametro_conta_valor.update_attributes(params[:parametro_conta_valor])
      flash[:notice] = 'Parâmetro atualizado com sucesso!'
      redirect_to parametro_conta_valores_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @parametro_conta_valor.destroy
    flash[:notice] = 'Parâmetro excluído com sucesso!'
    redirect_to(parametro_conta_valores_url)
  end
  
  private 
  
  def so_pode_alterar_parametros_desta_unidade
    if params[:id]
      @parametro_conta_valor = ParametroContaValor.find params[:id]
      unless @parametro_conta_valor.unidade_id == session[:unidade_id].to_i
        flash[:notice] = 'Esse parâmetro pertence a outra unidade.'
        redirect_to("/login")
      end
    end
  end
  
end
