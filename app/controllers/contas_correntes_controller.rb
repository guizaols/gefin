class ContasCorrentesController < ApplicationController

#  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_conta_corrente, :auto_complete_for_conta_corrente_com_filtro_por_identificador]

  before_filter :so_pode_alterar_contas_corrente_desta_unidade

  PERMISSOES = { 
    CUD => Perfil::ManipularDadosDasContasCorrentes,
    'any' => Perfil::ContasCorrentes    
  }

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_conta_corrente, :auto_complete_for_conta_corrente_com_filtro_por_identificador]

  def auto_complete_for_conta_corrente
    find_options = {
      :conditions => ["(LOWER(numero_conta) LIKE ?) OR (LOWER(descricao) LIKE ?)", params['argumento'].formatar_para_like, params['argumento'].formatar_para_like] }

    @items = ContasCorrente.find_all_by_unidade_id session[:unidade_id], find_options
    render :text =>'<ul>' + @items.collect{|c| "<li lang=\"#{c.conta_contabil.id}_#{c.conta_contabil.codigo_contabil} - #{c.conta_contabil.nome}\" id=#{c.id}>#{c.resumo_conta_corrente}</li>"}.join + '</ul>'
  end

  def auto_complete_for_conta_corrente_com_filtro_por_identificador
    find_options = {
      :conditions => ["identificador = ? AND ((LOWER(numero_conta) LIKE ?) OR (LOWER(descricao) LIKE ?))", ContasCorrente::BANCO, params['argumento'].formatar_para_like, params['argumento'].formatar_para_like] }

    @items = ContasCorrente.find_all_by_unidade_id session[:unidade_id], find_options
    render :text =>'<ul>' + @items.collect{|c| "<li lang=\"#{c.conta_contabil.id}_#{c.conta_contabil.nome}\" id=#{c.id}>#{c.resumo_conta_corrente}</li>"}.join + '</ul>'
  end

  def index
    @contas_correntes = ContasCorrente.find_all_by_unidade_id(session[:unidade_id], :order => 'descricao ASC')
  end

  def show
  end

  def new
    @contas_corrente = ContasCorrente.new
  end

  def edit
    @contas_corrente = ContasCorrente.find_by_id_and_unidade_id(params[:id], session[:unidade_id])
  end

  def create
    @contas_corrente = ContasCorrente.new(params[:contas_corrente])
    @contas_corrente.unidade_id = session[:unidade_id]
    if @contas_corrente.save
      flash[:notice] = 'Conta Corrente criada com sucesso!'
      redirect_to contas_correntes_path
    else
      render :action => "new"
    end
  end

  def update
    if @contas_corrente.update_attributes(params[:contas_corrente])
      flash[:notice] = 'Conta Corrente atualizada com sucesso!'
      redirect_to contas_correntes_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @contas_corrente.destroy
    flash[:notice] = 'Conta Corrente excluída com sucesso!'
    redirect_to(contas_correntes_url)
  end

  private

  def so_pode_alterar_contas_corrente_desta_unidade
    if params[:id]
      @contas_corrente = ContasCorrente.find params[:id]
      unless @contas_corrente.unidade_id == session[:unidade_id].to_i
        flash[:notice] = 'Essa Conta a Corrente pertence a outra unidade.'
        redirect_to login_path
      end
    end
  end

end
