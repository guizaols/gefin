class AgenciasController < ApplicationController

  #  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_agencias_do_banco, :auto_complete_for_agencia]

  before_filter :so_pode_alterar_agencias_desta_entidade

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDasAgencias,
    'any' => Perfil::Agencias
  }

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_agencias_do_banco, :auto_complete_for_agencia]

  def index
    @agencias = Agencia.find_all_by_entidade_id(@unidade.entidade_id, :order => 'nome ASC')
  end

  def show
  end

  def new
    @agencia = Agencia.new
  end

  def edit
  end

  def create
    @agencia = Agencia.new(params[:agencia])
    @agencia.entidade_id = @unidade.entidade_id
    if @agencia.save
      flash[:notice] = 'Agência criada com sucesso!'
      redirect_to agencias_path
    else
      render :action => "new"
    end
  end

  def update
    if @agencia.update_attributes(params[:agencia])
      flash[:notice] = 'Agência atualizada com sucesso!'
      redirect_to agencias_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @agencia.destroy
    flash[:notice] = 'Agência excluída com sucesso!'    
    redirect_to(agencias_url)
  end
  
  def auto_complete_for_agencias_do_banco
    find_options = {
      :conditions => [ "entidade_id = ?  AND  banco_id = ? AND ((LOWER(nome) LIKE ?) or (LOWER(numero) LIKE ?))", @unidade.entidade_id, params[:banco_id], params['argumento'].formatar_para_like, params['argumento'].formatar_para_like],
      :order => "nome ASC" }
    @itens = Agencia.find(:all, find_options)
    render :text =>'<ul>' + @itens.collect{|c| "<li id=#{c.id}>#{c.numero} - #{c.nome}</li>"}.join + '</ul>'
  end  
  
  def auto_complete_for_agencia
    find_options = { 
      :conditions => [ "entidade_id = ? AND ((LOWER(nome) LIKE ?) or (LOWER(numero) LIKE ?))", @unidade.entidade_id, params['argumento'].formatar_para_like, params['argumento'].formatar_para_like],
      :order => "nome ASC" }

    @items = Agencia.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.id}> #{c.numero} - #{c.nome}</li>"}.join + '</ul>'
  end

  def importar_agencias
    retorno = Agencia.importar_agencias(params[:entidade].to_i, @unidade.entidade_id)
    render :update do |page|
      page.alert retorno.last
      page << 'window.location.reload()'
    end
  end

  private

  def so_pode_alterar_agencias_desta_entidade
    @unidade = Unidade.find session[:unidade_id]
    
    if params[:id]
      @agencia = Agencia.find params[:id]
      unless @agencia.entidade_id == @unidade.entidade_id
        flash[:notice] = 'Essa Agência pertence a outra entidade.'
        redirect_to login_path
      end
    end
  end
  
end
